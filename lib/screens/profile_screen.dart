/// LumiSpire - the player profile & skills.
///
/// The player sets their name and age (which picks their maturity tier and so
/// the difficulty of everything they see), reviews the skills they have
/// gathered per subject, and — for demos — loads a ready-made save. The
/// per-subject skill bars are the "gathering data on skills and educational
/// level" signal, kept entirely on the player's own POD.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/services/game_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = GameRepository.instance;
  final _nameController = TextEditingController();
  bool _busy = false;
  bool _nameSynced = false;

  @override
  void initState() {
    super.initState();
    _repo.load().then((_) {
      if (mounted) {
        setState(() {
          _nameController.text = _repo.profile.displayName;
          _nameSynced = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _seed() async {
    setState(() => _busy = true);
    await _repo.seedDemo();
    if (!mounted) return;
    setState(() {
      _nameController.text = _repo.profile.displayName;
      _busy = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Demo save loaded — explore worlds, wardrobe and more!',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        final profile = _repo.profile;
        if (!_nameSynced) _nameController.text = profile.displayName;
        final maxSkill = profile.skillXp.values.isEmpty
            ? 1
            : profile.skillXp.values.reduce((a, b) => a > b ? a : b);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'My explorer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSubmitted: (v) => _repo.setName(v),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Age: ${profile.ageYears}  ·  ${profile.tier.label}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Your age sets how hard your adventures are — from '
                      '${MaturityTier.sprout.label} to ${MaturityTier.pioneer.label}.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: profile.ageYears.toDouble(),
                      min: 2,
                      max: 50,
                      divisions: 48,
                      label: '${profile.ageYears}',
                      onChanged: _busy ? null : (v) => _repo.setAge(v.round()),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _repo.setName(_nameController.text),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Skills gathered',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'The more you explore a subject, the taller its bar grows.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    for (final subject in Subject.values)
                      _SkillBar(
                        subject: subject,
                        xp: profile.skillXp[subject.name] ?? 0,
                        max: maxSkill,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try it instantly',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Load a ready-made demo save with coins, progress and '
                      'cosmetics so you can explore every feature right away.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _busy ? null : _seed,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Load demo save'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.subject, required this.xp, required this.max});
  final Subject subject;
  final int xp;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(subject.icon, color: subject.color, size: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              subject.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : (xp / max).clamp(0.0, 1.0),
                minHeight: 10,
                color: subject.color,
                backgroundColor: subject.color.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              '$xp',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

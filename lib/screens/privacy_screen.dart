/// LumiSpire - data ownership, consent and sharing.
///
/// LumiSpire gathers learning signals (skills, progress, educational level) — so
/// where that data lives and who can see it matters enormously, especially for
/// young players. This screen makes the promise concrete:
///
///  * everything is **encrypted on the player's own Solid POD** (LumiSpire keeps
///    no copy);
///  * **consent** is explicit, with a parental-consent toggle for children;
///  * a grown-up or teacher can be given **read-only** access to progress using
///    Solid access control (WAC/ACP) — `grantPermission` / `readPermission` /
///    `revokePermission` — and it can be revoked at any time.

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show
        AccessMode,
        RecipientType,
        SolidFunctionCallStatus,
        getWebId,
        grantPermission,
        readPermission,
        revokePermission;

import 'package:lumispire_app/constants/app.dart';
import 'package:lumispire_app/services/game_repository.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _repo = GameRepository.instance;
  final _recipientController = TextEditingController();
  bool _busy = false;
  bool _consent = false;
  String? _myWebId;
  String? _status;
  Map<dynamic, dynamic> _shares = {};

  @override
  void initState() {
    super.initState();
    _repo.load();
    _init();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final id = await getWebId();
      if (!mounted) return;
      setState(() => _myWebId = id);
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _status = 'Could not read your WebID: $e');
    }
  }

  Future<void> _refresh() async {
    try {
      final perms = await readPermission(fileName: progressFile, isFile: true);
      if (mounted) setState(() => _shares = perms);
    } catch (_) {
      if (mounted) setState(() => _shares = {});
    }
  }

  Future<void> _share() async {
    final recipient = _recipientController.text.trim();
    final me = _myWebId;
    if (recipient.isEmpty || me == null) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final result = await grantPermission(
        fileName: progressFile,
        permissionList: [AccessMode.read],
        recipientType: RecipientType.individual,
        recipientWebIdList: [recipient],
        ownerWebId: me,
        granterWebId: me,
        isFile: true,
      );
      final ok = result == SolidFunctionCallStatus.success;
      setState(() {
        _status = ok
            ? 'Shared read-only with $recipient. You can revoke this anytime.'
            : 'Sharing did not complete (status: $result).';
        if (ok) {
          _recipientController.clear();
          _consent = false;
        }
      });
      await _refresh();
    } catch (e) {
      setState(() => _status = 'Could not share: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _revoke(String recipient) async {
    final me = _myWebId;
    if (me == null) return;
    setState(() => _busy = true);
    try {
      await revokePermission(
        fileName: progressFile,
        permissionList: [AccessMode.read],
        recipientIndOrGroupWebId: recipient,
        ownerWebId: me,
        granterWebId: me,
        recipientType: RecipientType.individual,
        isFile: true,
      );
      setState(() => _status = 'Access revoked for $recipient.');
      await _refresh();
    } catch (e) {
      setState(() => _status = 'Could not revoke: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<String> get _sharedWith {
    final out = <String>[];
    _shares.forEach((k, v) {
      final id = k.toString();
      if (id.startsWith('http') && id != _myWebId) out.add(id);
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        final profile = _repo.profile;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your data, your rules',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const _OwnCard(
              icon: Icons.lock_rounded,
              title: 'Everything is locked with your key',
              body:
                  'Your progress, coins and skills are scrambled (encrypted) '
                  'and kept in your own online locker — your Solid POD. '
                  'LumiSpire keeps no copy, so nobody else can read your data.',
            ),
            const _OwnCard(
              icon: Icons.eco_rounded,
              title: 'We only keep what the game needs',
              body:
                  'No hidden tracking and nothing is ever sold. That is called '
                  'data minimisation.',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consent',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: profile.dataConsent,
                      onChanged: (v) => _repo.setConsent(data: v),
                      title: const Text(
                        'I agree to LumiSpire saving my learning progress on '
                        'my POD.',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: profile.parentalConsent,
                      onChanged: (v) => _repo.setConsent(parental: v),
                      title: const Text(
                        'A parent or guardian has said this is okay.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_myWebId != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_rounded),
                  title: const Text('Your WebID'),
                  subtitle: Text(_myWebId!),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share progress with a grown-up or teacher',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter their Solid WebID to give them read-only access to '
                      'your progress file.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient WebID',
                        hintText: 'https://their-pod.example/profile/card#me',
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _consent,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _consent = v ?? false),
                      title: const Text(
                        'I consent to sharing my progress with this person.',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: (_consent && !_busy) ? _share : null,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Grant read access'),
                    ),
                  ],
                ),
              ),
            ),
            if (_status != null)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_status!),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Currently shared with',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_sharedWith.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nobody. Your progress is visible only to you.'),
                ),
              )
            else
              for (final id in _sharedWith)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_rounded),
                    title: Text(id),
                    subtitle: const Text('Read-only'),
                    trailing: TextButton.icon(
                      onPressed: _busy ? null : () => _revoke(id),
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: const Text('Revoke'),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _OwnCard extends StatelessWidget {
  const _OwnCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LumiSpire - playing a level (the core game loop).
///
/// A short quiz: one question at a time, immediate right/wrong feedback with a
/// teaching explanation, then a results screen that awards XP + coins through
/// [GameRepository.completeLevel] (which also unlocks/levels up) and offers to
/// continue or replay. Every question teaches, win or lose.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/services/game_repository.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.worldId, required this.levelId});
  final String worldId;
  final String levelId;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _repo = GameRepository.instance;

  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _revealed = false;
  bool _finished = false;
  ({int xp, int coins, bool firstClear})? _reward;

  GameWorld? get _world => worldById(widget.worldId);
  GameLevel? get _level {
    final w = _world;
    if (w == null) return null;
    for (final l in w.levels) {
      if (l.id == widget.levelId) return l;
    }
    return null;
  }

  void _pick(int i) {
    if (_revealed) return;
    setState(() {
      _picked = i;
      _revealed = true;
      if (i == _level!.questions[_index].correctIndex) _correct++;
    });
  }

  Future<void> _next() async {
    final level = _level!;
    if (_index < level.questions.length - 1) {
      setState(() {
        _index++;
        _picked = null;
        _revealed = false;
      });
    } else {
      final reward = await _repo.completeLevel(
        world: _world!,
        level: level,
        correct: _correct,
        total: level.questions.length,
      );
      if (!mounted) return;
      setState(() {
        _finished = true;
        _reward = reward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final world = _world;
    final level = _level;
    if (world == null || level == null) {
      return const Scaffold(body: Center(child: Text('Level not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: _finished
          ? _Results(
              world: world,
              level: level,
              correct: _correct,
              total: level.questions.length,
              reward: _reward!,
              onDone: () => Navigator.of(context).pop(),
            )
          : _QuestionView(
              world: world,
              question: level.questions[_index],
              index: _index,
              count: level.questions.length,
              picked: _picked,
              revealed: _revealed,
              onPick: _pick,
              onNext: _next,
            ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.world,
    required this.question,
    required this.index,
    required this.count,
    required this.picked,
    required this.revealed,
    required this.onPick,
    required this.onNext,
  });

  final GameWorld world;
  final Question question;
  final int index;
  final int count;
  final int? picked;
  final bool revealed;
  final ValueChanged<int> onPick;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (index + 1) / count,
              minHeight: 8,
              color: world.color,
              backgroundColor: world.color.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Question ${index + 1} of $count',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 20),
          Text(
            question.prompt,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < question.options.length; i++)
            _Option(
              text: question.options[i],
              state: !revealed
                  ? _OptState.idle
                  : i == question.correctIndex
                  ? _OptState.correct
                  : (i == picked ? _OptState.wrong : _OptState.idle),
              onTap: () => onPick(i),
            ),
          const Spacer(),
          if (revealed) ...[
            if (question.explanation.isNotEmpty)
              Card(
                color: scheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('💡  '),
                      Expanded(child: Text(question.explanation)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(backgroundColor: world.color),
              child: Text(index < count - 1 ? 'Next' : 'Finish'),
            ),
          ],
        ],
      ),
    );
  }
}

enum _OptState { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color border, Widget? trailing) = switch (state) {
      _OptState.correct => (
        const Color(0xFF0ca30c).withValues(alpha: 0.15),
        const Color(0xFF0ca30c),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF0ca30c)),
      ),
      _OptState.wrong => (
        const Color(0xFFd03b3b).withValues(alpha: 0.12),
        const Color(0xFFd03b3b),
        const Icon(Icons.cancel_rounded, color: Color(0xFFd03b3b)),
      ),
      _OptState.idle => (
        scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        scheme.outlineVariant,
        null,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.world,
    required this.level,
    required this.correct,
    required this.total,
    required this.reward,
    required this.onDone,
  });

  final GameWorld world;
  final GameLevel level;
  final int correct;
  final int total;
  final ({int xp, int coins, bool firstClear}) reward;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final perfect = correct == total;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(perfect ? '🌟' : '🎉', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              perfect ? 'Perfect!' : 'Nice work!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You got $correct of $total right.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RewardPill(label: '+${reward.xp} XP', color: world.color),
                const SizedBox(width: 12),
                _RewardPill(
                  label: '+${reward.coins} 🪙',
                  color: const Color(0xFFF4C430),
                ),
              ],
            ),
            if (!reward.firstClear) ...[
              const SizedBox(height: 12),
              Text(
                'Replay bonus (reduced reward)',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onDone,
              style: FilledButton.styleFrom(backgroundColor: world.color),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to the world'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

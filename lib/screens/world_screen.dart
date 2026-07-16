/// LumiSpire - inside a world: the level path.
///
/// Shows a world's levels as an ordered journey. Cleared levels are ticked,
/// the next one is highlighted, and levels above the player's maturity tier are
/// shown but locked. Tapping an available level starts it.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/screens/play_screen.dart';
import 'package:lumispire_app/services/game_repository.dart';
import 'package:lumispire_app/services/progression.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key, required this.worldId});
  final String worldId;

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final _repo = GameRepository.instance;
  static const _prog = Progression();

  @override
  Widget build(BuildContext context) {
    final world = worldById(widget.worldId);
    if (world == null) {
      return const Scaffold(body: Center(child: Text('World not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(world.name)),
      body: AnimatedBuilder(
        animation: _repo,
        builder: (context, _) {
          final profile = _repo.profile;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(world.tagline, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              if (world.levels.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'This world is still being built. Check back soon for '
                      'new adventures!',
                    ),
                  ),
                ),
              for (var idx = 0; idx < world.levels.length; idx++)
                _LevelTile(
                  index: idx,
                  world: world,
                  level: world.levels[idx],
                  done: profile.completedLevelIds.contains(
                    world.levels[idx].id,
                  ),
                  available: _prog.isLevelAvailable(
                    world,
                    world.levels[idx],
                    profile,
                  ),
                  onPlay: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayScreen(
                        worldId: world.id,
                        levelId: world.levels[idx].id,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.index,
    required this.world,
    required this.level,
    required this.done,
    required this.available,
    required this.onPlay,
  });

  final int index;
  final GameWorld world;
  final GameLevel level;
  final bool done;
  final bool available;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = world.color;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: done
              ? color
              : available
              ? color.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest,
          foregroundColor: done ? Colors.white : color,
          child: done
              ? const Icon(Icons.check_rounded)
              : available
              ? Text('${index + 1}')
              : const Icon(Icons.lock_rounded, size: 18),
        ),
        title: Text(
          level.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          available
              ? '${level.questions.length} questions · ${level.xpReward} XP · '
                    '🪙${level.coinReward}'
              : 'Unlocks for ${level.minTier.label} (ages ${level.minTier.minAge}+)',
        ),
        trailing: available
            ? FilledButton(
                onPressed: onPlay,
                style: FilledButton.styleFrom(backgroundColor: color),
                child: Text(done ? 'Replay' : 'Play'),
              )
            : const Icon(Icons.lock_outline_rounded),
      ),
    );
  }
}

/// LumiSpire - the world map (home).
///
/// The player's hub: a header with their level, XP bar and coins, then a grid
/// of explorable worlds. Each world card reflects its state — open to explore,
/// locked behind coins, gated to an older maturity tier, or a "coming soon"
/// teaser. Tapping an open world dives into it.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/screens/world_screen.dart';
import 'package:lumispire_app/services/game_repository.dart';
import 'package:lumispire_app/services/progression.dart';

class WorldMap extends StatefulWidget {
  const WorldMap({super.key});

  @override
  State<WorldMap> createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
  final _repo = GameRepository.instance;
  static const _prog = Progression();

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  Future<void> _tryUnlock(GameWorld world) async {
    final ok = await _repo.unlockWorld(world);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Unlocked ${world.name}! Have fun exploring.'
                : 'You need ${world.unlockCost} coins to unlock ${world.name}.',
          ),
        ),
      );
  }

  void _enter(GameWorld world) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => WorldScreen(worldId: world.id)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        if (_repo.isLoading && !_repo.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = _repo.profile;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PlayerHeader(
              name: profile.displayName,
              level: _repo.playerLevel,
              progress: _repo.levelProgress,
              coins: profile.coins,
              tier: profile.tier,
            ),
            const SizedBox(height: 20),
            Text(
              'Choose a world to explore',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 900
                    ? 3
                    : c.maxWidth > 560
                    ? 2
                    : 1;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    for (final world in gameWorlds)
                      _WorldCard(
                        world: world,
                        tierAllowed: _prog.isTierAllowed(world, profile),
                        unlocked: _prog.isUnlocked(world, profile),
                        canEnter: _prog.canEnter(world, profile),
                        progress: _prog.worldProgress(world, profile),
                        onEnter: () => _enter(world),
                        onUnlock: () => _tryUnlock(world),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.name,
    required this.level,
    required this.progress,
    required this.coins,
    required this.tier,
  });

  final String name;
  final int level;
  final double progress;
  final int coins;
  final MaturityTier tier;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primary,
                  child: Text(
                    'Lv$level',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '${tier.label} · ages ${tier.minAge}–${tier.maxAge}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _CoinPill(coins: coins),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: scheme.surface.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).round()}% to level ${level + 1}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4C430),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙 '),
          Text(
            '$coins',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5a4600),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    required this.world,
    required this.tierAllowed,
    required this.unlocked,
    required this.canEnter,
    required this.progress,
    required this.onEnter,
    required this.onUnlock,
  });

  final GameWorld world;
  final bool tierAllowed;
  final bool unlocked;
  final bool canEnter;
  final double progress;
  final VoidCallback onEnter;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = world.color;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: canEnter ? onEnter : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.18),
                    foregroundColor: color,
                    child: Icon(world.icon),
                  ),
                  const Spacer(),
                  if (world.comingSoon)
                    _chip(context, 'Coming soon', scheme.outline)
                  else if (!tierAllowed)
                    _chip(
                      context,
                      'Ages ${world.minTier.minAge}+',
                      scheme.tertiary,
                    )
                  else if (!unlocked)
                    _chip(context, '🪙 ${world.unlockCost}', scheme.secondary),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                world.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  world.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              if (canEnter) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: onEnter,
                    style: FilledButton.styleFrom(backgroundColor: color),
                    child: Text(progress > 0 ? 'Continue' : 'Explore'),
                  ),
                ),
              ] else if (!world.comingSoon && tierAllowed && !unlocked)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: onUnlock,
                    child: Text('Unlock 🪙${world.unlockCost}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

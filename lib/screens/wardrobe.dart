/// LumiSpire - the avatar wardrobe & shop.
///
/// Spend earned coins on skins, hats, outfits and houses, then equip them onto
/// your avatar. Inspired by the dress-up / cosmetic-economy loop of games like
/// Dress to Impress and Animal Crossing — the reward for learning is expressing
/// yourself. Purchases and equipped items persist encrypted on the player's POD.

library;

import 'package:flutter/material.dart';

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/services/game_repository.dart';

class Wardrobe extends StatefulWidget {
  const Wardrobe({super.key});

  @override
  State<Wardrobe> createState() => _WardrobeState();
}

class _WardrobeState extends State<Wardrobe> {
  final _repo = GameRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  Future<void> _tap(CosmeticItem item) async {
    final owned =
        _repo.profile.ownedItemIds.contains(item.id) || item.cost == 0;
    if (owned) {
      await _repo.equip(item);
      return;
    }
    final bought = await _repo.buyItem(item);
    if (!mounted) return;
    if (bought) {
      await _repo.equip(item);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'You need ${item.cost} coins for ${item.name}. '
              'Explore more worlds to earn them!',
            ),
          ),
        );
    }
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
            _AvatarPreview(repo: _repo),
            const SizedBox(height: 20),
            for (final type in CosmeticType.values) ...[
              Text(type.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final item in cosmeticCatalogue.where(
                    (c) => c.type == type,
                  ))
                    _ItemCard(
                      item: item,
                      owned:
                          profile.ownedItemIds.contains(item.id) ||
                          item.cost == 0,
                      equipped: _repo.isEquipped(item),
                      affordable: profile.coins >= item.cost,
                      onTap: () => _tap(item),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.repo});
  final GameRepository repo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final equipped = repo.profile.equipped;
    final skin = cosmeticById(equipped['skin'] ?? 'skin_default');
    final hat = cosmeticById(equipped['hat'] ?? '');
    final house = cosmeticById(equipped['house'] ?? '');
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Text(skin?.emoji ?? '🙂', style: const TextStyle(fontSize: 72)),
                if (hat != null)
                  Positioned(
                    top: -6,
                    child: Text(
                      hat.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your home: ${house?.emoji ?? '⛺'}  ${house?.name ?? 'Starter tent'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🪙 ${repo.profile.coins} to spend',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.owned,
    required this.equipped,
    required this.affordable,
    required this.onTap,
  });

  final CosmeticItem item;
  final bool owned;
  final bool equipped;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: equipped
              ? item.color.withValues(alpha: 0.18)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: equipped ? item.color : scheme.outlineVariant,
            width: equipped ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 6),
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            if (equipped)
              _tag(context, 'Worn', scheme.primary)
            else if (owned)
              _tag(context, 'Wear', item.color)
            else
              _tag(
                context,
                '🪙 ${item.cost}',
                affordable ? scheme.secondary : scheme.outline,
              ),
          ],
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
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

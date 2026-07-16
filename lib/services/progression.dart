/// LumiSpire - pure progression rules.
///
/// Kept separate from storage and UI so the game's maths — player level from
/// XP, whether a world is unlocked, how far through a world you are — is simple
/// to reason about and to unit-test.

library;

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/models/player_profile.dart';

class Progression {
  const Progression();

  /// XP needed to *reach* a given player level. Level 1 is 0 XP; each level
  /// costs a bit more than the last (a gentle quadratic curve).
  int xpForLevel(int level) => level <= 1 ? 0 : 100 * (level - 1) * level ~/ 2;

  /// The player's current level from their total XP.
  int levelForXp(int totalXp) {
    var level = 1;
    while (xpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  /// Progress (0.0–1.0) toward the next level.
  double levelProgress(int totalXp) {
    final level = levelForXp(totalXp);
    final start = xpForLevel(level);
    final next = xpForLevel(level + 1);
    if (next == start) return 1;
    return ((totalXp - start) / (next - start)).clamp(0.0, 1.0);
  }

  /// Whether [world] is open to [profile]: it must be within the player's
  /// maturity tier, and either free, already unlocked, or (for a preview of
  /// affordability) purchasable. Being *enterable* requires free-or-unlocked.
  bool isTierAllowed(GameWorld world, PlayerProfile profile) =>
      profile.tier.index >= world.minTier.index;

  bool isUnlocked(GameWorld world, PlayerProfile profile) =>
      world.unlockCost == 0 || profile.unlockedWorldIds.contains(world.id);

  bool canEnter(GameWorld world, PlayerProfile profile) =>
      isTierAllowed(world, profile) &&
      isUnlocked(world, profile) &&
      !world.comingSoon;

  bool canAfford(GameWorld world, PlayerProfile profile) =>
      profile.coins >= world.unlockCost;

  /// Whether a level is playable for the player (unlocked world + tier gate).
  bool isLevelAvailable(
    GameWorld world,
    GameLevel level,
    PlayerProfile profile,
  ) => canEnter(world, profile) && profile.tier.index >= level.minTier.index;

  /// How many of [world]'s levels the player has completed.
  int completedCount(GameWorld world, PlayerProfile profile) => world.levels
      .where((l) => profile.completedLevelIds.contains(l.id))
      .length;

  /// A world's completion fraction (0.0–1.0), 0 if it has no levels yet.
  double worldProgress(GameWorld world, PlayerProfile profile) =>
      world.levels.isEmpty
      ? 0
      : completedCount(world, profile) / world.levels.length;

  /// XP awarded for a level given how many questions were answered correctly.
  /// Full reward for a perfect run, scaled down (never below a third) otherwise.
  int xpAward(GameLevel level, int correct, int total) {
    if (total == 0) return level.xpReward;
    final ratio = (correct / total).clamp(0.34, 1.0);
    return (level.xpReward * ratio).round();
  }

  int coinAward(GameLevel level, int correct, int total) {
    if (total == 0) return level.coinReward;
    final ratio = (correct / total).clamp(0.34, 1.0);
    return (level.coinReward * ratio).round();
  }

  /// Total number of worlds a player can currently see as playable.
  int playableWorldCount(PlayerProfile profile) =>
      gameWorlds.where((w) => canEnter(w, profile)).length;
}

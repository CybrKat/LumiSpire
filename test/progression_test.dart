/// Deterministic tests for LumiSpire's progression rules.

import 'package:flutter_test/flutter_test.dart';

import 'package:lumispire_app/content/worlds.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/models/player_profile.dart';
import 'package:lumispire_app/services/progression.dart';

void main() {
  const prog = Progression();

  group('player level from XP', () {
    test('starts at level 1 with no XP', () {
      expect(prog.levelForXp(0), 1);
    });

    test('level increases monotonically with XP', () {
      var last = 1;
      for (var xp = 0; xp <= 5000; xp += 100) {
        final lvl = prog.levelForXp(xp);
        expect(lvl, greaterThanOrEqualTo(last));
        last = lvl;
      }
    });

    test('progress is between 0 and 1', () {
      for (final xp in [0, 50, 150, 600, 1234]) {
        final p = prog.levelProgress(xp);
        expect(p, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('maturity tiers', () {
    test('map ages to the right band', () {
      expect(MaturityTier.forAge(3), MaturityTier.sprout);
      expect(MaturityTier.forAge(7), MaturityTier.explorer);
      expect(MaturityTier.forAge(11), MaturityTier.pathfinder);
      expect(MaturityTier.forAge(15), MaturityTier.voyager);
      expect(MaturityTier.forAge(40), MaturityTier.pioneer);
      expect(MaturityTier.forAge(99), MaturityTier.pioneer);
    });
  });

  group('world gating', () {
    final child = PlayerProfile(ageYears: 7); // Explorer tier, 50 coins
    final teen = PlayerProfile(ageYears: 15); // Voyager tier

    test('free tier-appropriate world is enterable', () {
      final numberIsles = worldById('number_isles')!;
      expect(prog.canEnter(numberIsles, child), isTrue);
    });

    test('coin-locked world is not enterable until unlocked', () {
      final cyber = worldById('cyber_harbour')!; // costs 40, Explorer+
      expect(prog.isUnlocked(cyber, child), isFalse);
      expect(prog.canEnter(cyber, child), isFalse);
      final unlocked = child.copyWith(unlockedWorldIds: {'cyber_harbour'});
      expect(prog.canEnter(cyber, unlocked), isTrue);
    });

    test('coming-soon world is never enterable', () {
      final story = worldById('story_glade')!;
      final rich = teen.copyWith(
        coins: 9999,
        unlockedWorldIds: {'story_glade'},
      );
      expect(prog.canEnter(story, rich), isFalse);
    });

    test('a level above the player tier is unavailable', () {
      final numberIsles = worldById('number_isles')!;
      // num_4 (Algebra) requires Voyager; a child cannot play it.
      final algebra = numberIsles.levels.firstWhere((l) => l.id == 'num_4');
      expect(prog.isLevelAvailable(numberIsles, algebra, child), isFalse);
      expect(prog.isLevelAvailable(numberIsles, algebra, teen), isTrue);
    });
  });

  group('rewards', () {
    test('perfect run gives full reward', () {
      final level = worldById('number_isles')!.levels.first;
      expect(prog.xpAward(level, 2, 2), level.xpReward);
      expect(prog.coinAward(level, 2, 2), level.coinReward);
    });

    test('a wrong answer reduces but never zeroes the reward', () {
      final level = worldById('number_isles')!.levels.first;
      final xp = prog.xpAward(level, 0, 2);
      expect(xp, lessThan(level.xpReward));
      expect(xp, greaterThan(0));
    });
  });
}

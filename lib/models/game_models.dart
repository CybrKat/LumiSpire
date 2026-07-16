/// LumiSpire - the core game domain.
///
/// LumiSpire is a world-exploring learning game: each explorable **world**
/// teaches a **subject** (numeracy, literacy, cybersecurity, …) through a path
/// of increasingly hard **levels**. Clearing levels earns XP and coins, which
/// unlock new worlds and cosmetic items for the player's avatar. Difficulty and
/// which worlds are available scale with the player's **maturity tier** (age),
/// from tiny sprouts to adults building real-world skills.
///
/// These are the immutable building blocks; the player's mutable progress lives
/// in [PlayerProfile], and the actual worlds/levels are defined in
/// `lib/content/worlds.dart`.

library;

import 'package:flutter/material.dart';

/// Age-based difficulty bands. A player only sees worlds and level content at
/// or below their tier, so a 4-year-old and a 40-year-old get very different
/// journeys through the same subjects.

enum MaturityTier {
  sprout('Sprout', 2, 4),
  explorer('Explorer', 5, 8),
  pathfinder('Pathfinder', 9, 12),
  voyager('Voyager', 13, 17),
  pioneer('Pioneer', 18, 50);

  const MaturityTier(this.label, this.minAge, this.maxAge);

  final String label;
  final int minAge;
  final int maxAge;

  /// The tier an [age] in years falls into (clamped to the ends of the range).
  static MaturityTier forAge(int age) {
    for (final t in values) {
      if (age <= t.maxAge) return t;
    }
    return pioneer;
  }

  static MaturityTier fromName(String? name) =>
      values.firstWhere((t) => t.name == name, orElse: () => explorer);
}

/// The school-of-life subjects LumiSpire teaches.

enum Subject {
  numeracy('Numeracy', Icons.calculate_rounded, Color(0xFF3DA5D9)),
  literacy('Literacy', Icons.menu_book_rounded, Color(0xFFEA7317)),
  emotions('Emotional intelligence', Icons.favorite_rounded, Color(0xFFE84D8A)),
  history('History', Icons.account_balance_rounded, Color(0xFFB07219)),
  cyber('Cybersecurity', Icons.shield_rounded, Color(0xFF2EC4B6)),
  politics('Politics & society', Icons.how_to_vote_rounded, Color(0xFF7B5EA7)),
  digital('Digital skills', Icons.devices_rounded, Color(0xFF4361EE)),
  coding('Coding', Icons.code_rounded, Color(0xFF6A994E)),
  health('Health & wellbeing', Icons.spa_rounded, Color(0xFF2A9D8F));

  const Subject(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static Subject fromName(String? name) =>
      values.firstWhere((s) => s.name == name, orElse: () => numeracy);
}

/// A single multiple-choice question inside a level.

class Question {
  const Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;

  /// Shown after answering, so every question also teaches.
  final String explanation;
}

/// One level within a world: a short set of questions with rewards. Levels are
/// ordered; [minTier] gates the harder ones to older players.

class GameLevel {
  const GameLevel({
    required this.id,
    required this.title,
    required this.minTier,
    required this.questions,
    this.xpReward = 50,
    this.coinReward = 20,
  });

  final String id;
  final String title;
  final MaturityTier minTier;
  final List<Question> questions;
  final int xpReward;
  final int coinReward;
}

/// An explorable area, themed around one [subject].

class GameWorld {
  const GameWorld({
    required this.id,
    required this.name,
    required this.tagline,
    required this.subject,
    required this.minTier,
    required this.levels,
    this.unlockCost = 0,
    this.icon = Icons.public_rounded,
    this.comingSoon = false,
  });

  final String id;
  final String name;
  final String tagline;
  final Subject subject;

  /// Minimum maturity tier that can enter this world.
  final MaturityTier minTier;

  final List<GameLevel> levels;

  /// Coins required to unlock. 0 means it is open from the start.
  final int unlockCost;

  final IconData icon;

  /// A world whose levels are not built yet (shown as a teaser).
  final bool comingSoon;

  Color get color => subject.color;
}

/// Cosmetic items the player can buy with coins and equip on their avatar.

enum CosmeticType {
  skin('Skin'),
  outfit('Outfit'),
  hat('Hat'),
  house('House');

  const CosmeticType(this.label);
  final String label;

  static CosmeticType fromName(String? name) =>
      values.firstWhere((t) => t.name == name, orElse: () => skin);
}

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    required this.emoji,
    this.color = const Color(0xFF7B5EA7),
  });

  final String id;
  final String name;
  final CosmeticType type;
  final int cost;

  /// A simple emoji stands in for real art in this vertical slice.
  final String emoji;
  final Color color;
}

/// LumiSpire - the player's saved progress.
///
/// This is the one mutable, persisted object in the game: coins, XP, which
/// levels are cleared, which worlds and cosmetics are unlocked, what the avatar
/// is wearing, and the per-subject skill scores the platform gathers as the
/// player learns. It also carries the player's age (which sets their maturity
/// tier) and their consent flags.
///
/// It is stored **encrypted on the player's own Solid POD** — LumiSpire keeps
/// no copy, and a child's learning data never sits on someone else's server.

library;

import 'package:lumispire_app/models/game_models.dart';

class PlayerProfile {
  PlayerProfile({
    this.displayName = 'Explorer',
    this.ageYears = 8,
    this.coins = 50,
    this.totalXp = 0,
    Set<String> completedLevelIds = const {},
    Set<String> unlockedWorldIds = const {},
    Set<String> ownedItemIds = const {},
    Map<String, String> equipped = const {},
    Map<String, int> skillXp = const {},
    this.dataConsent = false,
    this.parentalConsent = false,
  }) : completedLevelIds = Set.unmodifiable(completedLevelIds),
       unlockedWorldIds = Set.unmodifiable(unlockedWorldIds),
       ownedItemIds = Set.unmodifiable(ownedItemIds),
       equipped = Map.unmodifiable(equipped),
       skillXp = Map.unmodifiable(skillXp);

  final String displayName;
  final int ageYears;
  final int coins;
  final int totalXp;

  /// IDs of [GameLevel]s the player has cleared.
  final Set<String> completedLevelIds;

  /// IDs of [GameWorld]s the player has unlocked (beyond the free ones).
  final Set<String> unlockedWorldIds;

  /// IDs of [CosmeticItem]s the player owns.
  final Set<String> ownedItemIds;

  /// Equipped cosmetics, keyed by [CosmeticType.name] → item id.
  final Map<String, String> equipped;

  /// XP earned per [Subject.name] — the "skills gathered" signal.
  final Map<String, int> skillXp;

  /// Whether the player consents to their learning data being gathered.
  final bool dataConsent;

  /// Whether a parent/guardian has consented (for younger players).
  final bool parentalConsent;

  /// The maturity tier derived from the player's age.
  MaturityTier get tier => MaturityTier.forAge(ageYears);

  PlayerProfile copyWith({
    String? displayName,
    int? ageYears,
    int? coins,
    int? totalXp,
    Set<String>? completedLevelIds,
    Set<String>? unlockedWorldIds,
    Set<String>? ownedItemIds,
    Map<String, String>? equipped,
    Map<String, int>? skillXp,
    bool? dataConsent,
    bool? parentalConsent,
  }) => PlayerProfile(
    displayName: displayName ?? this.displayName,
    ageYears: ageYears ?? this.ageYears,
    coins: coins ?? this.coins,
    totalXp: totalXp ?? this.totalXp,
    completedLevelIds: completedLevelIds ?? this.completedLevelIds,
    unlockedWorldIds: unlockedWorldIds ?? this.unlockedWorldIds,
    ownedItemIds: ownedItemIds ?? this.ownedItemIds,
    equipped: equipped ?? this.equipped,
    skillXp: skillXp ?? this.skillXp,
    dataConsent: dataConsent ?? this.dataConsent,
    parentalConsent: parentalConsent ?? this.parentalConsent,
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'ageYears': ageYears,
    'coins': coins,
    'totalXp': totalXp,
    'completedLevelIds': completedLevelIds.toList(),
    'unlockedWorldIds': unlockedWorldIds.toList(),
    'ownedItemIds': ownedItemIds.toList(),
    'equipped': equipped,
    'skillXp': skillXp,
    'dataConsent': dataConsent,
    'parentalConsent': parentalConsent,
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    displayName: json['displayName'] as String? ?? 'Explorer',
    ageYears: (json['ageYears'] as num?)?.toInt() ?? 8,
    coins: (json['coins'] as num?)?.toInt() ?? 50,
    totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    completedLevelIds: {
      for (final v in (json['completedLevelIds'] as List? ?? const []))
        v as String,
    },
    unlockedWorldIds: {
      for (final v in (json['unlockedWorldIds'] as List? ?? const []))
        v as String,
    },
    ownedItemIds: {
      for (final v in (json['ownedItemIds'] as List? ?? const [])) v as String,
    },
    equipped: {
      for (final e in (json['equipped'] as Map? ?? const {}).entries)
        e.key as String: e.value as String,
    },
    skillXp: {
      for (final e in (json['skillXp'] as Map? ?? const {}).entries)
        e.key as String: (e.value as num).toInt(),
    },
    dataConsent: json['dataConsent'] as bool? ?? false,
    parentalConsent: json['parentalConsent'] as bool? ?? false,
  );
}

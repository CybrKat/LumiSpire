/// LumiSpire - load and persist the player's progress on their Solid POD.
///
/// Mirrors the pattern LillithApp uses: a single [PlayerProfile] is kept in
/// memory as the source of truth for the session and written back **encrypted**
/// (`writePod(encrypted: true)`) after every change. It is a [ChangeNotifier]
/// so the game UI rebuilds whenever coins, XP, unlocks or the avatar change.
///
/// The game rules themselves live in [Progression]; this class only reads,
/// mutates and saves state.

library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:solidpod/solidpod.dart'
    show readPod, writePod, ResourceNotExistException;

import 'package:lumispire_app/constants/app.dart';
import 'package:lumispire_app/models/game_models.dart';
import 'package:lumispire_app/models/player_profile.dart';
import 'package:lumispire_app/services/progression.dart';

class GameRepository extends ChangeNotifier {
  GameRepository._();

  static final GameRepository instance = GameRepository._();

  static const _progression = Progression();

  PlayerProfile _profile = PlayerProfile();
  bool _loaded = false;
  bool _loading = false;
  String? _error;

  PlayerProfile get profile => _profile;
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;
  String? get error => _error;

  int get playerLevel => _progression.levelForXp(_profile.totalXp);
  double get levelProgress => _progression.levelProgress(_profile.totalXp);

  /// Load progress from the POD. A missing document (first play) is not an
  /// error — the player simply starts fresh with a small coin float.
  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final content = await readPod(progressFile);
      if (content.trim().isNotEmpty) {
        _profile = PlayerProfile.fromJson(
          jsonDecode(content) as Map<String, dynamic>,
        );
      }
      _loaded = true;
    } on ResourceNotExistException {
      _profile = PlayerProfile();
      _loaded = true;
    } catch (e) {
      _error = 'Could not load your progress: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Set the player's age (which determines their maturity tier), then persist.
  Future<void> setAge(int age) async {
    _profile = _profile.copyWith(ageYears: age.clamp(2, 50));
    await _save();
  }

  /// Set the player's display name, then persist.
  Future<void> setName(String name) async {
    _profile = _profile.copyWith(
      displayName: name.trim().isEmpty ? _profile.displayName : name.trim(),
    );
    await _save();
  }

  /// Record consent flags, then persist.
  Future<void> setConsent({bool? data, bool? parental}) async {
    _profile = _profile.copyWith(
      dataConsent: data ?? _profile.dataConsent,
      parentalConsent: parental ?? _profile.parentalConsent,
    );
    await _save();
  }

  /// Complete a level: award XP + coins (scaled by [correct]/[total]) and add
  /// the subject skill XP. Re-completing a level still gives a small top-up but
  /// not the full first-clear reward. Persists and returns the reward granted.
  Future<({int xp, int coins, bool firstClear})> completeLevel({
    required GameWorld world,
    required GameLevel level,
    required int correct,
    required int total,
  }) async {
    final firstClear = !_profile.completedLevelIds.contains(level.id);
    var xp = _progression.xpAward(level, correct, total);
    var coins = _progression.coinAward(level, correct, total);
    if (!firstClear) {
      // Replays give a quarter reward so grinding is possible but muted.
      xp = (xp * 0.25).round();
      coins = (coins * 0.25).round();
    }

    final completed = {..._profile.completedLevelIds, level.id};
    final skill = {..._profile.skillXp};
    skill.update(world.subject.name, (v) => v + xp, ifAbsent: () => xp);

    _profile = _profile.copyWith(
      totalXp: _profile.totalXp + xp,
      coins: _profile.coins + coins,
      completedLevelIds: completed,
      skillXp: skill,
    );
    await _save();
    return (xp: xp, coins: coins, firstClear: firstClear);
  }

  /// Spend coins to unlock a world. Returns false if the player cannot afford
  /// it or it is not allowed for their tier.
  Future<bool> unlockWorld(GameWorld world) async {
    if (!_progression.isTierAllowed(world, _profile)) return false;
    if (_progression.isUnlocked(world, _profile)) return true;
    if (_profile.coins < world.unlockCost) return false;
    _profile = _profile.copyWith(
      coins: _profile.coins - world.unlockCost,
      unlockedWorldIds: {..._profile.unlockedWorldIds, world.id},
    );
    await _save();
    return true;
  }

  /// Buy a cosmetic item with coins. Returns false if unaffordable.
  Future<bool> buyItem(CosmeticItem item) async {
    if (_profile.ownedItemIds.contains(item.id)) return true;
    if (_profile.coins < item.cost) return false;
    _profile = _profile.copyWith(
      coins: _profile.coins - item.cost,
      ownedItemIds: {..._profile.ownedItemIds, item.id},
    );
    await _save();
    return true;
  }

  /// Equip an owned cosmetic in its slot, then persist.
  Future<void> equip(CosmeticItem item) async {
    if (!_profile.ownedItemIds.contains(item.id) && item.cost != 0) return;
    _profile = _profile.copyWith(
      equipped: {..._profile.equipped, item.type.name: item.id},
    );
    await _save();
  }

  /// Whether [item] is currently equipped in its slot.
  bool isEquipped(CosmeticItem item) =>
      _profile.equipped[item.type.name] == item.id;

  /// Seed a demo save: a Pioneer-age explorer with coins, a couple of worlds
  /// unlocked and some progress, so the whole game can be shown end-to-end.
  Future<void> seedDemo() async {
    _profile = PlayerProfile(
      displayName: 'Demo Explorer',
      ageYears: 15,
      coins: 500,
      totalXp: 320,
      completedLevelIds: {'num_1', 'num_2', 'cyber_1'},
      unlockedWorldIds: {'cyber_harbour'},
      ownedItemIds: {'skin_default', 'skin_cat', 'hat_wizard'},
      equipped: {'skin': 'skin_cat', 'hat': 'hat_wizard'},
      skillXp: {'numeracy': 220, 'cyber': 100},
      dataConsent: true,
      parentalConsent: true,
    );
    await _save();
  }

  Future<void> _save() async {
    _error = null;
    notifyListeners();
    try {
      await writePod(
        progressFile,
        jsonEncode(_profile.toJson()),
        encrypted: true,
        overwrite: true,
      );
    } catch (e) {
      _error = 'Saved locally but could not sync to your POD: $e';
    } finally {
      notifyListeners();
    }
  }
}

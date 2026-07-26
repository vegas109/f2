import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/player_profile.dart';

/// Owns the [PlayerProfile] and all economy mutations (XP, energy, crystals).
///
/// All reward/spend logic funnels through here so it can later be moved
/// behind a server (Cloud Functions) for anti-cheat without changing callers.
class PlayerController extends StateNotifier<PlayerProfile> {
  PlayerController(this._prefs, this._userId)
      : super(const PlayerProfile()) {
    _restore();
    _applyPassiveEnergyRefill();
  }

  final SharedPreferences _prefs;
  final String _userId;

  String get _key => 'player_$_userId';

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        state = PlayerProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _prefs.remove(_key);
      }
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }

  void _set(PlayerProfile next) {
    state = next;
    _save();
  }

  // --- Time-based energy regeneration ---
  void _applyPassiveEnergyRefill() {
    if (state.energy >= AppConstants.maxEnergy) return;
    if (state.lastEnergyRefillMs == 0) return;
    final elapsed =
        DateTime.now().millisecondsSinceEpoch - state.lastEnergyRefillMs;
    final regenerated =
        elapsed ~/ AppConstants.energyRefillInterval.inMilliseconds;
    if (regenerated <= 0) return;
    final newEnergy =
        (state.energy + regenerated).clamp(0, AppConstants.maxEnergy);
    _set(state.copyWith(
      energy: newEnergy,
      lastEnergyRefillMs:
          newEnergy >= AppConstants.maxEnergy ? 0 : state.lastEnergyRefillMs,
    ));
  }

  // --- Mutations ---

  void selectTrack(String trackId) =>
      _set(state.copyWith(selectedTrack: trackId));

  void addXp(int amount) => _set(state.copyWith(xp: state.xp + amount));

  void addCrystals(int amount) =>
      _set(state.copyWith(crystals: state.crystals + amount));

  /// Spends [amount] crystals. Returns false if the player can't afford it.
  bool spendCrystals(int amount) {
    if (state.crystals < amount) return false;
    _set(state.copyWith(crystals: state.crystals - amount));
    return true;
  }

  /// Consumes one energy on a mistake. Starts the refill timer if needed.
  void loseEnergy() {
    if (state.energy <= 0) return;
    final wasFull = state.energy >= AppConstants.maxEnergy;
    _set(state.copyWith(
      energy: state.energy - AppConstants.energyCostPerMistake,
      lastEnergyRefillMs: wasFull
          ? DateTime.now().millisecondsSinceEpoch
          : state.lastEnergyRefillMs,
    ));
  }

  /// Instantly refills energy for crystals. Returns false if unaffordable.
  bool refillEnergyForCrystals() {
    if (state.energy >= AppConstants.maxEnergy) return true;
    if (!spendCrystals(AppConstants.energyRefillCostCrystals)) return false;
    _set(state.copyWith(
      energy: AppConstants.maxEnergy,
      lastEnergyRefillMs: 0,
    ));
    return true;
  }

  /// Marks a lesson complete, awards XP, updates the daily streak, and
  /// returns the XP granted (0 if already completed).
  int completeLesson(String lessonId, {int xp = AppConstants.xpPerLesson}) {
    _updateStreak();
    if (state.completedLessonIds.contains(lessonId)) return 0;
    final updated = {...state.completedLessonIds, lessonId};
    _set(state.copyWith(
      completedLessonIds: updated,
      xp: state.xp + xp,
    ));
    return xp;
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Advances or resets the streak based on the last active day.
  void _updateStreak() {
    final now = DateTime.now();
    final today = _dayKey(now);
    if (state.lastActiveDay == today) return; // already counted today
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    final newStreak =
        state.lastActiveDay == yesterday ? state.streak + 1 : 1;
    _set(state.copyWith(streak: newStreak, lastActiveDay: today));
  }

  bool isLessonCompleted(String lessonId) =>
      state.completedLessonIds.contains(lessonId);
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerProfile>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final auth = ref.watch(authControllerProvider);
  final userId = auth.user?.id ?? 'anonymous';
  return PlayerController(prefs, userId);
});

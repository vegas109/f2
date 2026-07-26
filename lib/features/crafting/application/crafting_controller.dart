import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';
import '../domain/cosmetic.dart';

class CraftingState {
  const CraftingState({this.parts = 0, this.unlocked = const {}});
  final int parts;
  final Set<String> unlocked;

  CraftingState copyWith({int? parts, Set<String>? unlocked}) => CraftingState(
        parts: parts ?? this.parts,
        unlocked: unlocked ?? this.unlocked,
      );
}

/// Tracks crafting "parts" (dropped from lessons) and unlocked cosmetics.
class CraftingController extends StateNotifier<CraftingState> {
  CraftingController(this._prefs, this._userId)
      : super(const CraftingState()) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _userId;
  String get _key => 'crafting_$_userId';

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      state = CraftingState(
        parts: (json['parts'] as num?)?.toInt() ?? 0,
        unlocked:
            ((json['unlocked'] as List?)?.cast<String>() ?? const []).toSet(),
      );
    } catch (_) {/* ignore corrupt state */}
  }

  void _save() {
    _prefs.setString(
      _key,
      jsonEncode({'parts': state.parts, 'unlocked': state.unlocked.toList()}),
    );
  }

  void addParts(int n) {
    state = state.copyWith(parts: state.parts + n);
    _save();
  }

  bool isUnlocked(String id) => state.unlocked.contains(id);

  /// Crafts a cosmetic if enough parts. Returns false if unaffordable/owned.
  bool craft(Cosmetic item) {
    if (state.unlocked.contains(item.id)) return false;
    if (state.parts < item.cost) return false;
    state = state.copyWith(
      parts: state.parts - item.cost,
      unlocked: {...state.unlocked, item.id},
    );
    _save();
    return true;
  }
}

final craftingControllerProvider =
    StateNotifierProvider<CraftingController, CraftingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final userId = ref.watch(authControllerProvider).user?.id ?? 'anonymous';
  return CraftingController(prefs, userId);
});

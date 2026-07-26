import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';
import '../domain/cosmetic.dart';

class CraftingState {
  const CraftingState({
    this.parts = 0,
    this.unlocked = const {},
    this.equippedAvatar,
    this.equippedSkin,
  });

  final int parts;
  final Set<String> unlocked;

  /// Cosmetic ids currently equipped, by slot.
  final String? equippedAvatar;
  final String? equippedSkin;

  CraftingState copyWith({
    int? parts,
    Set<String>? unlocked,
    String? equippedAvatar,
    String? equippedSkin,
  }) =>
      CraftingState(
        parts: parts ?? this.parts,
        unlocked: unlocked ?? this.unlocked,
        equippedAvatar: equippedAvatar ?? this.equippedAvatar,
        equippedSkin: equippedSkin ?? this.equippedSkin,
      );

  /// The emoji of the equipped avatar, or null if none.
  String? get equippedAvatarEmoji {
    if (equippedAvatar == null) return null;
    for (final c in Cosmetic.catalog) {
      if (c.id == equippedAvatar) return c.emoji;
    }
    return null;
  }
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
        equippedAvatar: json['equippedAvatar'] as String?,
        equippedSkin: json['equippedSkin'] as String?,
      );
    } catch (_) {/* ignore corrupt state */}
  }

  void _save() {
    _prefs.setString(
      _key,
      jsonEncode({
        'parts': state.parts,
        'unlocked': state.unlocked.toList(),
        'equippedAvatar': state.equippedAvatar,
        'equippedSkin': state.equippedSkin,
      }),
    );
  }

  /// Equips an owned cosmetic into its slot (avatar/skin).
  void equip(Cosmetic item) {
    if (!state.unlocked.contains(item.id)) return;
    state = item.kind == 'avatar'
        ? state.copyWith(equippedAvatar: item.id)
        : state.copyWith(equippedSkin: item.id);
    _save();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/application/auth_controller.dart';

/// Holds the user's chosen app locale. `null` means "follow the system".
///
/// Persisted globally (not per user) so the choice survives sign-out.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  static Locale? _read(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    return (code == null || code.isEmpty) ? null : Locale(code);
  }

  /// Pass null to fall back to the system locale.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});

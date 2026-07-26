import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';

/// Tracks whether the first-run onboarding has been completed.
///
/// Persisted globally (not per user) so it only shows once per install.
class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._prefs)
      : super(_prefs.getBool(_key) ?? false);

  final SharedPreferences _prefs;
  static const _key = 'onboarding_seen';

  bool get seen => state;

  Future<void> complete() async {
    state = true;
    await _prefs.setBool(_key, true);
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) {
  return OnboardingController(ref.watch(sharedPreferencesProvider));
});

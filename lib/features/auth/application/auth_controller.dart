import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_user.dart';

/// Authentication state exposed to the app.
class AuthState {
  const AuthState({this.user, this.isLoading = false});

  final AppUser? user;
  final bool isLoading;

  bool get isSignedIn => user != null;

  AuthState copyWith({AppUser? user, bool? isLoading, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Local-mode auth controller.
///
/// This persists a user to [SharedPreferences] so the app is fully usable
/// without Firebase configuration. Replace [signInWithEmail],
/// [signInWithGoogle] and [signInWithApple] with real FirebaseAuth calls
/// once `flutterfire configure` has been run — the rest of the app only
/// depends on [AuthState].
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._prefs) : super(const AuthState()) {
    _restore();
  }

  final SharedPreferences _prefs;
  static const _key = 'auth_user';

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        state = AuthState(
          user: AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        _prefs.remove(_key);
      }
    }
  }

  Future<void> _persist(AppUser user) async {
    await _prefs.setString(_key, jsonEncode(user.toJson()));
  }

  String _idFromEmail(String email) =>
      'local_${email.trim().toLowerCase().hashCode.toUnsigned(32)}';

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true);
    // NOTE: local mode does not verify passwords. Swap for FirebaseAuth.
    final name = email.contains('@') ? email.split('@').first : 'Coder';
    final user = AppUser(
      id: _idFromEmail(email),
      displayName: name,
      email: email.trim(),
    );
    await _persist(user);
    state = AuthState(user: user);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    // TODO(firebase): use google_sign_in + FirebaseAuth credential.
    const user = AppUser(
      id: 'local_google',
      displayName: 'Google Coder',
      email: 'coder@gmail.com',
    );
    await _persist(user);
    state = const AuthState(user: user);
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true);
    // TODO(firebase): use sign_in_with_apple + FirebaseAuth credential.
    const user = AppUser(
      id: 'local_apple',
      displayName: 'Apple Coder',
    );
    await _persist(user);
    state = const AuthState(user: user);
  }

  Future<void> continueAsGuest() async {
    final user = AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest',
      isGuest: true,
    );
    await _persist(user);
    state = AuthState(user: user);
  }

  Future<void> signOut() async {
    await _prefs.remove(_key);
    state = const AuthState(clearUser: true);
  }
}

/// Must be overridden in main() with the loaded SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not initialized'),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(sharedPreferencesProvider));
});

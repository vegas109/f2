import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/application/onboarding_controller.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

/// App router with onboarding + auth-gated redirects.
///
/// Watches [authControllerProvider] so navigation reacts to sign in/out.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final seenOnboarding = ref.read(onboardingControllerProvider);

      // First run: force onboarding until completed/skipped.
      if (!seenOnboarding) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (loc == '/onboarding') return '/login';

      final signedIn = ref.read(authControllerProvider).isSignedIn;
      final loggingIn = loc == '/login';
      if (!signedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    refreshListenable: _AuthRefresh(ref),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
      ),
    ],
  );
});

/// Bridges Riverpod auth changes to GoRouter's [Listenable] refresh.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

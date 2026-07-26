import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _emailMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  const SizedBox(height: 28),
                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  if (_emailMode) ...[
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: l10n.emailHint),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(hintText: l10n.passwordHint),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => controller.signInWithEmail(
                                _emailCtrl.text,
                                _passwordCtrl.text,
                              ),
                      child: Text(l10n.signIn),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _emailMode = false),
                      child: const Text('← Back'),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _emailMode = true),
                      icon: const Icon(Icons.email_outlined),
                      label: Text(l10n.continueWithEmail),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed:
                          auth.isLoading ? null : controller.signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: Text(l10n.continueWithGoogle),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed:
                          auth.isLoading ? null : controller.signInWithApple,
                      icon: const Icon(Icons.apple),
                      label: Text(l10n.continueWithApple),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed:
                          auth.isLoading ? null : controller.continueAsGuest,
                      child: Text(l10n.continueAsGuest),
                    ),
                  ],
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        '{ }',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

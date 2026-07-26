import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'code_execution_service.dart';

/// Provides the app's [CodeExecutionService].
///
/// Swap the implementation here to migrate from public Piston to a secured
/// Cloud Functions proxy or self-hosted Judge0 without touching the UI.
final codeExecutionServiceProvider = Provider<CodeExecutionService>((ref) {
  final service = PistonCodeExecutionService();
  ref.onDispose(() {
    // http.Client created internally is closed by GC; nothing to dispose here,
    // but the hook is kept for a client injected in tests.
  });
  return service;
});

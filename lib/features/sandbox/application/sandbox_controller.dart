import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../code_execution/application/code_execution_providers.dart';
import '../../code_execution/domain/execution_result.dart';
import '../../code_execution/domain/programming_language.dart';

class SandboxState {
  const SandboxState({
    this.language = ProgrammingLanguage.python,
    this.isRunning = false,
    this.result,
    this.errorMessage,
  });

  final ProgrammingLanguage language;
  final bool isRunning;
  final ExecutionResult? result;
  final String? errorMessage;

  SandboxState copyWith({
    ProgrammingLanguage? language,
    bool? isRunning,
    ExecutionResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return SandboxState(
      language: language ?? this.language,
      isRunning: isRunning ?? this.isRunning,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SandboxController extends StateNotifier<SandboxState> {
  SandboxController(this._ref) : super(const SandboxState());

  final Ref _ref;

  void setLanguage(ProgrammingLanguage language) {
    state = state.copyWith(
      language: language,
      clearResult: true,
      clearError: true,
    );
  }

  Future<void> run(String sourceCode, {String stdin = ''}) async {
    state = state.copyWith(
      isRunning: true,
      clearResult: true,
      clearError: true,
    );
    final service = _ref.read(codeExecutionServiceProvider);
    final result = await service.run(
      language: state.language,
      sourceCode: sourceCode,
      stdin: stdin,
    );
    result.when(
      success: (value) =>
          state = state.copyWith(isRunning: false, result: value),
      failure: (message, _) =>
          state = state.copyWith(isRunning: false, errorMessage: message),
    );
  }
}

final sandboxControllerProvider =
    StateNotifierProvider<SandboxController, SandboxState>(
  (ref) => SandboxController(ref),
);

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/result.dart';
import '../domain/execution_result.dart';
import '../domain/programming_language.dart';

/// Abstraction over a remote code-execution backend.
///
/// The concrete implementation currently talks to the public Piston API
/// directly. When you move to a secured setup (a Cloud Functions proxy that
/// hides an API key, or self-hosted Judge0), implement this same interface
/// and swap it in the provider — nothing else in the app changes.
abstract interface class CodeExecutionService {
  Future<Result<ExecutionResult>> run({
    required ProgrammingLanguage language,
    required String sourceCode,
    String stdin = '',
  });
}

/// [CodeExecutionService] backed by the public Piston API (emkc.org).
class PistonCodeExecutionService implements CodeExecutionService {
  PistonCodeExecutionService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Result<ExecutionResult>> run({
    required ProgrammingLanguage language,
    required String sourceCode,
    String stdin = '',
  }) async {
    final uri = Uri.parse('${AppConstants.pistonBaseUrl}/execute');
    final payload = <String, dynamic>{
      'language': language.pistonLanguage,
      'version': language.pistonVersion,
      'files': [
        {'name': language.fileName, 'content': sourceCode},
      ],
      'stdin': stdin,
      'compile_timeout': 10000,
      'run_timeout': 10000,
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(AppConstants.codeExecutionTimeout);

      if (response.statusCode == 429) {
        return const Failure(
          'Rate limit reached. Please wait a moment and try again.',
        );
      }
      if (response.statusCode != 200) {
        return Failure(
          'Execution failed (HTTP ${response.statusCode}).',
          response.body,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Success(_parse(json));
    } on FormatException catch (e) {
      return Failure('Could not parse execution response.', e);
    } catch (e) {
      // Covers SocketException, TimeoutException, ClientException, etc.
      return Failure(
        'Network error while running your code. Check your connection.',
        e,
      );
    }
  }

  ExecutionResult _parse(Map<String, dynamic> json) {
    final run = (json['run'] as Map<String, dynamic>?) ?? const {};
    final compile = json['compile'] as Map<String, dynamic>?;

    final signal = run['signal'];
    // Piston reports SIGKILL when the run_timeout is exceeded.
    final timedOut = signal == 'SIGKILL';

    return ExecutionResult(
      stdout: (run['stdout'] as String?) ?? '',
      stderr: (run['stderr'] as String?) ?? '',
      exitCode: (run['code'] as num?)?.toInt() ?? 0,
      compileOutput: compile == null
          ? null
          : ((compile['stderr'] as String?)?.isNotEmpty ?? false)
              ? compile['stderr'] as String
              : compile['stdout'] as String?,
      timedOut: timedOut,
    );
  }
}

import 'package:codehero/features/code_execution/domain/execution_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExecutionResult', () {
    test('isSuccess only when clean exit with no errors', () {
      const ok = ExecutionResult(stdout: '5\n', stderr: '', exitCode: 0);
      expect(ok.isSuccess, isTrue);

      const nonZero = ExecutionResult(stdout: '', stderr: '', exitCode: 1);
      expect(nonZero.isSuccess, isFalse);

      const withStderr =
          ExecutionResult(stdout: '', stderr: 'boom', exitCode: 0);
      expect(withStderr.isSuccess, isFalse);

      const compileErr = ExecutionResult(
          stdout: '', stderr: '', exitCode: 0, compileOutput: 'error: x');
      expect(compileErr.isSuccess, isFalse);
    });

    test('timedOut is never success', () {
      const timedOut = ExecutionResult(
          stdout: '', stderr: '', exitCode: 0, timedOut: true);
      expect(timedOut.isSuccess, isFalse);
    });

    test('consoleText falls back to placeholder when empty', () {
      const empty = ExecutionResult(stdout: '', stderr: '', exitCode: 0);
      expect(empty.consoleText, '(no output)');
    });

    test('consoleText includes stdout and labels stderr', () {
      const r = ExecutionResult(stdout: 'hi', stderr: 'oops', exitCode: 1);
      expect(r.consoleText, contains('hi'));
      expect(r.consoleText, contains('[stderr]'));
      expect(r.consoleText, contains('oops'));
    });
  });
}

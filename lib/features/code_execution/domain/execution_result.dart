/// Normalized result of running a piece of code through the execution API.
class ExecutionResult {
  const ExecutionResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    this.compileOutput,
    this.timedOut = false,
  });

  final String stdout;
  final String stderr;
  final int exitCode;

  /// Compiler diagnostics (C++). Null for interpreted languages.
  final String? compileOutput;

  final bool timedOut;

  /// True when the program compiled (if applicable) and exited with code 0
  /// and produced no error output.
  bool get isSuccess =>
      exitCode == 0 &&
      !timedOut &&
      (compileOutput == null || compileOutput!.trim().isEmpty) &&
      stderr.trim().isEmpty;

  /// A single combined message suitable for showing in the output console.
  String get consoleText {
    final buffer = StringBuffer();
    if (compileOutput != null && compileOutput!.trim().isNotEmpty) {
      buffer.writeln('[compile]');
      buffer.writeln(compileOutput!.trimRight());
    }
    if (stdout.trim().isNotEmpty) {
      buffer.writeln(stdout.trimRight());
    }
    if (stderr.trim().isNotEmpty) {
      buffer.writeln('[stderr]');
      buffer.writeln(stderr.trimRight());
    }
    if (timedOut) {
      buffer.writeln('[error] Execution timed out.');
    }
    final text = buffer.toString().trimRight();
    return text.isEmpty ? '(no output)' : text;
  }
}

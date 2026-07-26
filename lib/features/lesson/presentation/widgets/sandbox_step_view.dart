import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../code_execution/application/code_execution_providers.dart';
import '../../../code_execution/domain/programming_language.dart';
import '../../../curriculum/domain/lesson_step.dart';

/// A code-execution step: the learner writes code, runs it through Piston,
/// and the output is compared against [SandboxStep.expectedStdout].
class SandboxStepView extends ConsumerStatefulWidget {
  const SandboxStepView({
    super.key,
    required this.step,
    required this.language,
    required this.onCorrect,
    required this.onMistake,
  });

  final SandboxStep step;
  final ProgrammingLanguage language;
  final VoidCallback onCorrect;
  final VoidCallback onMistake;

  @override
  ConsumerState<SandboxStepView> createState() => _SandboxStepViewState();
}

class _SandboxStepViewState extends ConsumerState<SandboxStepView> {
  late final TextEditingController _codeCtrl;
  bool _running = false;
  String _output = '';
  bool? _passed;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.step.starterCode);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String _normalize(String s) =>
      s.replaceAll('\r\n', '\n').trimRight();

  Future<void> _run() async {
    setState(() {
      _running = true;
      _output = '';
      _passed = null;
    });
    final service = ref.read(codeExecutionServiceProvider);
    final result = await service.run(
      language: widget.language,
      sourceCode: _codeCtrl.text,
      stdin: widget.step.stdin,
    );
    if (!mounted) return;

    result.when(
      success: (exec) {
        final passed =
            _normalize(exec.stdout) == _normalize(widget.step.expectedStdout);
        setState(() {
          _running = false;
          _output = exec.consoleText;
          _passed = passed;
        });
        if (passed) {
          widget.onCorrect();
        } else {
          widget.onMistake();
        }
      },
      failure: (message, _) {
        setState(() {
          _running = false;
          _output = message;
          _passed = false;
        });
        // Network/rate-limit errors are not counted as a mistake.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.track(widget.language.id);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            widget.step.instructions,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: TextField(
              controller: _codeCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTheme.codeStyle(),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
        if (_output.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0B0F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _passed == true ? AppColors.success : AppColors.outline,
              ),
            ),
            child: Text(
              _passed == true ? '✓ ${l10n.feedbackCorrect}\n$_output' : _output,
              style: AppTheme.codeStyle(
                fontSize: 13,
                color:
                    _passed == true ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: accent),
            onPressed: _running
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    _run();
                  },
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_running ? l10n.sandboxRunning : l10n.actionRunCheck),
          ),
        ),
      ],
    );
  }
}

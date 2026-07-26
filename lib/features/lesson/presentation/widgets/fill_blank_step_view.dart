import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../curriculum/domain/lesson_step.dart';

/// Fill-in-the-blank step. Renders the code template with inline text fields
/// where `___` markers appear, and checks all answers on submit.
class FillBlankStepView extends StatefulWidget {
  const FillBlankStepView({
    super.key,
    required this.step,
    required this.showHints,
    required this.onCorrect,
    required this.onMistake,
  });

  final FillBlankStep step;
  final bool showHints;
  final VoidCallback onCorrect;
  final VoidCallback onMistake;

  @override
  State<FillBlankStepView> createState() => _FillBlankStepViewState();
}

class _FillBlankStepViewState extends State<FillBlankStepView> {
  late final List<TextEditingController> _controllers;
  bool? _lastCorrect;

  int get _blankCount => widget.step.answers.length;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(_blankCount, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _check() {
    var correct = true;
    for (var i = 0; i < _blankCount; i++) {
      final expected = widget.step.answers[i].trim();
      final actual = _controllers[i].text.trim();
      if (actual != expected) {
        correct = false;
        break;
      }
    }
    setState(() => _lastCorrect = correct);
    if (correct) {
      widget.onCorrect();
    } else {
      widget.onMistake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final segments = widget.step.segments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.step.prompt,
                  style: const TextStyle(fontSize: 17, height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0B0F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var i = 0; i < segments.length; i++) ...[
                        Text(segments[i], style: AppTheme.codeStyle()),
                        if (i < segments.length - 1 &&
                            i < _controllers.length)
                          _Blank(controller: _controllers[i]),
                      ],
                    ],
                  ),
                ),
                if (widget.showHints &&
                    widget.step.hint != null &&
                    widget.step.hint!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.step.hint!,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_lastCorrect == false) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Not quite — try again.',
                    style: TextStyle(color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _check,
            child: Text(AppLocalizations.of(context).actionCheck),
          ),
        ),
      ],
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextField(
        controller: controller,
        style: AppTheme.codeStyle(color: AppColors.python),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          filled: true,
          fillColor: AppColors.surfaceHigh,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

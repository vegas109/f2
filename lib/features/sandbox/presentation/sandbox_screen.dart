import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../code_execution/domain/programming_language.dart';
import '../application/sandbox_controller.dart';

class SandboxScreen extends ConsumerStatefulWidget {
  const SandboxScreen({super.key});

  @override
  ConsumerState<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends ConsumerState<SandboxScreen> {
  late final TextEditingController _codeCtrl;
  ProgrammingLanguage _lastLanguage = ProgrammingLanguage.python;

  @override
  void initState() {
    super.initState();
    _codeCtrl =
        TextEditingController(text: ProgrammingLanguage.python.starterCode);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _onLanguageChanged(ProgrammingLanguage lang) {
    ref.read(sandboxControllerProvider.notifier).setLanguage(lang);
    // Reset to starter code only if the user hasn't customized it.
    if (_codeCtrl.text.trim() == _lastLanguage.starterCode.trim() ||
        _codeCtrl.text.trim().isEmpty) {
      _codeCtrl.text = lang.starterCode;
    }
    _lastLanguage = lang;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sandboxControllerProvider);
    final accent = AppColors.track(state.language.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSandbox),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _LanguageToggle(
              value: state.language,
              onChanged: _onLanguageChanged,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EditorHeader(fileName: state.language.fileName, accent: accent),
                  const Divider(height: 1),
                  Expanded(
                    child: Scrollbar(
                      child: TextField(
                        controller: _codeCtrl,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                        style: AppTheme.codeStyle(),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                onPressed: state.isRunning
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        ref
                            .read(sandboxControllerProvider.notifier)
                            .run(_codeCtrl.text);
                      },
                icon: state.isRunning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(state.isRunning ? l10n.sandboxRunning : l10n.runCode),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _OutputConsole(state: state, l10n: l10n),
          ),
        ],
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.fileName, required this.accent});
  final String fileName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            fileName,
            style: AppTheme.codeStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputConsole extends StatelessWidget {
  const _OutputConsole({required this.state, required this.l10n});
  final SandboxState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final String text;
    Color color = AppColors.textSecondary;
    if (state.errorMessage != null) {
      text = state.errorMessage!;
      color = AppColors.error;
    } else if (state.result != null) {
      text = state.result!.consoleText;
      color = state.result!.isSuccess
          ? AppColors.textPrimary
          : AppColors.warning;
    } else {
      text = l10n.sandboxEmptyOutput;
      color = AppColors.textMuted;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0B0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                l10n.sandboxOutput,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (state.result != null || state.errorMessage != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded,
                      size: 16, color: AppColors.textMuted),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: text)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: AppTheme.codeStyle(fontSize: 13, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.value, required this.onChanged});
  final ProgrammingLanguage value;
  final ValueChanged<ProgrammingLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ProgrammingLanguage>(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.track(value.id).withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      segments: const [
        ButtonSegment(
          value: ProgrammingLanguage.python,
          label: Text('Python'),
        ),
        ButtonSegment(
          value: ProgrammingLanguage.cpp,
          label: Text('C++'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}

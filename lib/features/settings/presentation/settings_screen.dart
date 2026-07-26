import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Language options shown in settings. Add a row here + an ARB file to ship a
/// new language — nothing else needs to change.
const _languages = <_Lang>[
  _Lang(null, 'System default', '🌐'),
  _Lang('en', 'English', '🇬🇧'),
  _Lang('ru', 'Русский', '🇷🇺'),
  _Lang('es', 'Español', '🇪🇸'),
  _Lang('de', 'Deutsch', '🇩🇪'),
  _Lang('fr', 'Français', '🇫🇷'),
  _Lang('pt', 'Português', '🇵🇹'),
  _Lang('it', 'Italiano', '🇮🇹'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeControllerProvider)?.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(l10n.chooseLanguage,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          for (final lang in _languages)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String?>(
                value: lang.code,
                groupValue: current,
                onChanged: (value) => ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(value == null ? null : Locale(value)),
                activeColor: AppColors.primary,
                title: Text('${lang.flag}  ${lang.name}'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Lang {
  const _Lang(this.code, this.name, this.flag);
  final String? code;
  final String name;
  final String flag;
}

import 'package:codehero/core/localization/locale_controller.dart';
import 'package:codehero/features/settings/presentation/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('selecting a language updates the locale controller',
      (tester) async {
    final container = await pumpApp(tester, const SettingsScreen());

    expect(container.read(localeControllerProvider), isNull); // system default

    await tester.tap(find.textContaining('Русский'));
    await tester.pumpAndSettle();

    expect(container.read(localeControllerProvider)?.languageCode, 'ru');
  });
}

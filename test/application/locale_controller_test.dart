import 'package:codehero/core/localization/locale_controller.dart';
import 'package:codehero/features/auth/application/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
  });

  test('defaults to system (null) locale', () {
    expect(container.read(localeControllerProvider), isNull);
  });

  test('setLocale updates and persists; null clears it', () async {
    final ctrl = container.read(localeControllerProvider.notifier);
    await ctrl.setLocale(const Locale('es'));
    expect(container.read(localeControllerProvider)?.languageCode, 'es');

    // A fresh controller reads the persisted value.
    final prefs = await SharedPreferences.getInstance();
    final c2 = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(c2.dispose);
    expect(c2.read(localeControllerProvider)?.languageCode, 'es');

    await ctrl.setLocale(null);
    expect(container.read(localeControllerProvider), isNull);
  });
}

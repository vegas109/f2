import 'package:codehero/core/constants/app_constants.dart';
import 'package:codehero/features/auth/application/auth_controller.dart';
import 'package:codehero/features/player/application/player_controller.dart';
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

  PlayerController ctrl() =>
      container.read(playerControllerProvider.notifier);
  int xp() => container.read(playerControllerProvider).xp;
  int crystals() => container.read(playerControllerProvider).crystals;
  int energy() => container.read(playerControllerProvider).energy;
  int streak() => container.read(playerControllerProvider).streak;

  test('addXp increases xp', () {
    ctrl().addXp(30);
    expect(xp(), 30);
  });

  test('spendCrystals guards against overspend', () {
    expect(ctrl().spendCrystals(60), isFalse);
    expect(crystals(), 50);
    expect(ctrl().spendCrystals(20), isTrue);
    expect(crystals(), 30);
  });

  test('loseEnergy decrements and crystal refill restores to max', () {
    ctrl().loseEnergy();
    expect(energy(), AppConstants.maxEnergy - 1);
    expect(ctrl().refillEnergyForCrystals(), isTrue);
    expect(energy(), AppConstants.maxEnergy);
    expect(crystals(), 50 - AppConstants.energyRefillCostCrystals);
  });

  test('completeLesson awards xp once and starts a streak', () {
    expect(ctrl().completeLesson('l1', xp: 20), 20);
    expect(xp(), 20);
    expect(streak(), 1);
    // Same lesson again on the same day: no extra xp.
    expect(ctrl().completeLesson('l1', xp: 20), 0);
    expect(xp(), 20);
  });

  test('economy persists across controller instances', () async {
    ctrl().addCrystals(10);
    final prefs2 = await SharedPreferences.getInstance();
    final container2 = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs2),
    ]);
    addTearDown(container2.dispose);
    expect(container2.read(playerControllerProvider).crystals, 60);
  });
}

import 'package:codehero/features/auth/application/auth_controller.dart';
import 'package:codehero/features/crafting/application/crafting_controller.dart';
import 'package:codehero/features/crafting/domain/cosmetic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  final avatar = Cosmetic.catalog.firstWhere((c) => c.kind == 'avatar');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
  });

  CraftingController ctrl() =>
      container.read(craftingControllerProvider.notifier);
  CraftingState state() => container.read(craftingControllerProvider);

  test('craft requires enough parts and is one-time', () {
    expect(ctrl().craft(avatar), isFalse); // no parts yet
    ctrl().addParts(avatar.cost);
    expect(ctrl().craft(avatar), isTrue);
    expect(state().parts, 0);
    expect(ctrl().isUnlocked(avatar.id), isTrue);
    expect(ctrl().craft(avatar), isFalse); // already owned
  });

  test('equip sets the avatar slot and exposes its emoji', () {
    ctrl().addParts(avatar.cost);
    ctrl().craft(avatar);
    ctrl().equip(avatar);
    expect(state().equippedAvatar, avatar.id);
    expect(state().equippedAvatarEmoji, avatar.emoji);
  });

  test('cannot equip an unowned cosmetic', () {
    ctrl().equip(avatar);
    expect(state().equippedAvatar, isNull);
  });
}

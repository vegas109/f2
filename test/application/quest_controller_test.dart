import 'package:codehero/features/auth/application/auth_controller.dart';
import 'package:codehero/features/player/application/player_controller.dart';
import 'package:codehero/features/quests/application/quest_controller.dart';
import 'package:codehero/features/quests/domain/daily_quest.dart';
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

  DailyQuest questById(String id) =>
      container.read(questControllerProvider).firstWhere((q) => q.id == id);

  test('fresh quests are generated', () {
    expect(container.read(questControllerProvider), hasLength(3));
  });

  test('a flawless C++ lesson advances the right quests and pays out', () {
    container.read(questControllerProvider.notifier).recordLessonCompleted(
          trackId: 'cpp',
          mistakes: 0,
        );

    expect(questById('lessons2').progress, 1);
    expect(questById('flawless').progress, 1);
    expect(questById('flawless').claimed, isTrue);
    expect(questById('cpp1').progress, 1);
    expect(questById('cpp1').claimed, isTrue);

    // flawless (15) + cpp1 (15) auto-claimed on top of the starting 50.
    expect(container.read(playerControllerProvider).crystals, 80);
  });

  test('a lesson with mistakes does not advance the flawless quest', () {
    container.read(questControllerProvider.notifier).recordLessonCompleted(
          trackId: 'python',
          mistakes: 2,
        );
    expect(questById('flawless').progress, 0);
    expect(questById('lessons2').progress, 1);
  });
}

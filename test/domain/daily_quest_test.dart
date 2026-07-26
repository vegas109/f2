import 'package:codehero/features/quests/domain/daily_quest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyQuest', () {
    const quest = DailyQuest(
        id: 'q', title: 't', goal: 3, rewardCrystals: 10, progress: 1);

    test('isComplete and ratio track progress', () {
      expect(quest.isComplete, isFalse);
      expect(quest.ratio, closeTo(1 / 3, 1e-9));
      expect(quest.copyWith(progress: 3).isComplete, isTrue);
      expect(quest.copyWith(progress: 5).ratio, 1.0); // clamped
    });

    test('json round-trip', () {
      final restored = DailyQuest.fromJson(quest.toJson());
      expect(restored.id, 'q');
      expect(restored.goal, 3);
      expect(restored.progress, 1);
      expect(restored.claimed, isFalse);
    });
  });
}

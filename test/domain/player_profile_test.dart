import 'package:codehero/features/player/domain/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerProfile', () {
    test('level and progress derive from xp', () {
      expect(const PlayerProfile(xp: 0).level, 1);
      expect(const PlayerProfile(xp: 99).level, 1);
      expect(const PlayerProfile(xp: 100).level, 2);
      expect(const PlayerProfile(xp: 250).level, 3);
      expect(const PlayerProfile(xp: 150).levelProgress, closeTo(0.5, 1e-9));
    });

    test('hasEnergy reflects energy count', () {
      expect(const PlayerProfile(energy: 0).hasEnergy, isFalse);
      expect(const PlayerProfile(energy: 1).hasEnergy, isTrue);
    });

    test('json round-trip preserves state', () {
      const profile = PlayerProfile(
        xp: 120,
        crystals: 40,
        energy: 3,
        streak: 5,
        selectedTrack: 'cpp',
        lastEnergyRefillMs: 123,
        completedLessonIds: {'a', 'b'},
        lastActiveDay: '2026-07-26',
      );
      final restored = PlayerProfile.fromJson(profile.toJson());
      expect(restored, profile);
      expect(restored.completedLessonIds, {'a', 'b'});
    });

    test('copyWith overrides only given fields', () {
      const profile = PlayerProfile(xp: 10, crystals: 5);
      final next = profile.copyWith(xp: 20);
      expect(next.xp, 20);
      expect(next.crystals, 5);
    });
  });
}

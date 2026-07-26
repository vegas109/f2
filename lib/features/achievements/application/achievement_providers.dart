import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../crafting/application/crafting_controller.dart';
import '../../player/application/player_controller.dart';
import '../domain/achievement.dart';

/// Computes the current achievement stats snapshot from player + crafting.
final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final completed =
      ref.watch(playerControllerProvider.select((p) => p.completedLessonIds));
  final streak = ref.watch(playerControllerProvider.select((p) => p.streak));
  final cosmetics =
      ref.watch(craftingControllerProvider.select((s) => s.unlocked.length));

  final bosses = completed.where((id) => id.contains('boss')).length;

  return AchievementStats(
    lessonsCompleted: completed.length,
    bossesDefeated: bosses,
    streak: streak,
    cosmeticsOwned: cosmetics,
  );
});

/// Number of unlocked achievements (for the profile badge).
final unlockedAchievementCountProvider = Provider<int>((ref) {
  final stats = ref.watch(achievementStatsProvider);
  return Achievement.catalog.where((a) => a.isUnlocked(stats)).length;
});

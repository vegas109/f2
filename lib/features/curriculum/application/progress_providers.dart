import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/application/player_controller.dart';
import 'curriculum_providers.dart';

/// Completion stats for one track.
class TrackProgress {
  const TrackProgress({
    required this.trackId,
    required this.completed,
    required this.total,
  });

  final String trackId;
  final int completed;
  final int total;

  double get ratio => total == 0 ? 0 : completed / total;
  int get percent => (ratio * 100).round();
}

/// Loads both tracks and computes how many lessons the player has completed in
/// each. Recomputes when the completed-lessons set changes; track content is
/// cached by the repository so this is cheap.
final progressStatsProvider = FutureProvider<List<TrackProgress>>((ref) async {
  final repo = ref.watch(curriculumRepositoryProvider);
  final completed = ref.watch(
      playerControllerProvider.select((p) => p.completedLessonIds));

  final stats = <TrackProgress>[];
  for (final trackId in const ['python', 'cpp']) {
    final track = await repo.loadTrack(trackId);
    final lessons = track.allLessons;
    final done = lessons.where((l) => completed.contains(l.id)).length;
    stats.add(TrackProgress(
      trackId: trackId,
      completed: done,
      total: lessons.length,
    ));
  }
  return stats;
});

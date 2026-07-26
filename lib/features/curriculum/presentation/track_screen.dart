import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../lesson/presentation/lesson_player_screen.dart';
import '../../player/application/player_controller.dart';
import '../application/curriculum_providers.dart';
import '../domain/track.dart';
import 'widgets/lesson_tile.dart';

/// Lists a track's modules and lessons. Rows are flattened into a single list
/// and rendered lazily with a builder so long tracks stay cheap to scroll.
class TrackScreen extends ConsumerWidget {
  const TrackScreen({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackProvider(trackId));
    final accent = AppColors.track(trackId);

    return Scaffold(
      appBar: AppBar(
        title: Text(trackId == 'cpp' ? 'C++ Mastery' : 'Python Mastery'),
      ),
      body: trackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (track) {
          // Flatten modules + lessons into a single row list once.
          final rows = <Object>[];
          for (final module in track.modules) {
            rows.add(module);
            rows.addAll(module.lessons);
          }

          final completed = ref.watch(playerControllerProvider
              .select((p) => p.completedLessonIds));
          Lesson? next;
          for (final l in track.allLessons) {
            if (!completed.contains(l.id)) {
              next = l;
              break;
            }
          }

          return Column(
            children: [
              if (next != null)
                _ResumeBanner(track: track, lesson: next, accent: accent),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    if (row is Module) {
                      return _ModuleHeader(module: row, accent: accent);
                    }
                    return LessonTile(
                      trackId: track.id,
                      lesson: row as Lesson,
                      accent: accent,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({
    required this.track,
    required this.lesson,
    required this.accent,
  });
  final Track track;
  final Lesson lesson;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.9), accent.withOpacity(0.55)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Up next',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(lesson.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: accent,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    LessonPlayerScreen(trackId: track.id, lesson: lesson),
              ),
            ),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module, required this.accent});
  final Module module;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Flexible(
            child: Text(module.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(module.level,
                style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

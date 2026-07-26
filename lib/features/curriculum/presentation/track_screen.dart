import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../lesson/presentation/lesson_player_screen.dart';
import '../../player/application/player_controller.dart';
import '../application/curriculum_providers.dart';
import '../domain/track.dart';

/// Lists a track's modules and lessons and launches the lesson player.
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
        data: (track) => _TrackBody(track: track, accent: accent),
      ),
    );
  }
}

class _TrackBody extends ConsumerWidget {
  const _TrackBody({required this.track, required this.accent});
  final Track track;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final module in track.modules) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Row(
              children: [
                Text(module.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          ),
          for (final lesson in module.lessons)
            _LessonTile(
              lesson: lesson,
              accent: accent,
              completed: player.completedLessonIds.contains(lesson.id),
              onTap: () => _openLesson(context, ref, track.id, lesson),
            ),
        ],
      ],
    );
  }

  Future<void> _openLesson(
    BuildContext context,
    WidgetRef ref,
    String trackId,
    lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(trackId: trackId, lesson: lesson),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.accent,
    required this.completed,
    required this.onTap,
  });

  final dynamic lesson;
  final Color accent;
  final bool completed;
  final VoidCallback onTap;

  IconData get _formatIcon {
    switch (lesson.format.name) {
      case 'fillBlank':
        return Icons.edit_note_rounded;
      case 'sandbox':
        return Icons.terminal_rounded;
      case 'constructor':
        return Icons.widgets_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBoss = lesson.isBoss as bool;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isBoss ? AppColors.surfaceHigh : AppColors.surface,
      child: ListTile(
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: (isBoss ? AppColors.error : accent).withOpacity(0.16),
          child: Icon(
            isBoss ? Icons.whatshot_rounded : _formatIcon,
            color: isBoss ? AppColors.error : accent,
          ),
        ),
        title: Text(lesson.title as String,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isBoss ? 'Boss • timed • +${lesson.xpReward} XP' : '+${lesson.xpReward} XP',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: completed
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}

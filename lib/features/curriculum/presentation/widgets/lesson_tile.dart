import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../lesson/presentation/lesson_player_screen.dart';
import '../../../player/application/player_controller.dart';
import '../../domain/track.dart';

/// A tappable lesson row that launches the lesson player and shows completion.
class LessonTile extends ConsumerWidget {
  const LessonTile({
    super.key,
    required this.trackId,
    required this.lesson,
    required this.accent,
  });

  final String trackId;
  final Lesson lesson;
  final Color accent;

  IconData get _formatIcon => switch (lesson.format.name) {
        'fillBlank' => Icons.edit_note_rounded,
        'sandbox' => Icons.terminal_rounded,
        'constructor' => Icons.widgets_rounded,
        _ => Icons.menu_book_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(playerControllerProvider
        .select((p) => p.completedLessonIds.contains(lesson.id)));
    final isBoss = lesson.isBoss;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isBoss ? AppColors.surfaceHigh : AppColors.surface,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LessonPlayerScreen(trackId: trackId, lesson: lesson),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor:
              (isBoss ? AppColors.error : accent).withOpacity(0.16),
          child: Icon(
            isBoss ? Icons.whatshot_rounded : _formatIcon,
            color: isBoss ? AppColors.error : accent,
          ),
        ),
        title: Text(lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isBoss
              ? 'Boss • timed • +${lesson.xpReward} XP'
              : '+${lesson.xpReward} XP',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: completed
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ),
    );
  }
}

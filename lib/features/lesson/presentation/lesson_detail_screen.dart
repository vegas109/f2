import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../curriculum/domain/lesson_step.dart';
import '../../curriculum/domain/track.dart';
import 'lesson_player_screen.dart';

/// A read-only overview of a lesson: its theory and a preview of each step,
/// with a Start button that launches the interactive player.
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({
    super.key,
    required this.trackId,
    required this.lesson,
  });

  final String trackId;
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = AppColors.track(trackId);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (lesson.isBoss) _BossBanner(),
          Text('+${lesson.xpReward} XP',
              style: TextStyle(
                  color: accent, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text('${lesson.steps.length} steps',
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          for (var i = 0; i < lesson.steps.length; i++)
            _StepCard(index: i + 1, step: lesson.steps[i], accent: accent),
        ],
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accent),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.startLesson),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      LessonPlayerScreen(trackId: trackId, lesson: lesson),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BossBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.whatshot_rounded, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(
            child: Text('Boss fight — timed, and hints are hidden.',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.accent,
  });

  final int index;
  final LessonStep step;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final (String kind, String title, String? body, String? code) =
        _describe(step);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: accent.withOpacity(0.18),
                  child: Text('$index',
                      style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Text(kind.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            if (body != null && body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(body,
                  style: const TextStyle(
                      color: AppColors.textSecondary, height: 1.4)),
            ],
            if (code != null && code.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0B0F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(code, style: AppTheme.codeStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Maps a step to (kind, title, body, code) for display.
  (String, String, String?, String?) _describe(LessonStep step) {
    return switch (step) {
      TheoryStep s => ('Theory', s.heading, s.body, s.code),
      FillBlankStep s => ('Fill in the blank', s.prompt, s.hint, s.template),
      SandboxStep s => ('Code challenge', s.instructions, null, s.starterCode),
      ConstructorStep s => ('Build the code', s.instructions, null, null),
    };
  }
}

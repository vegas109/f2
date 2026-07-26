import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/track.dart';
import 'widgets/lesson_tile.dart';

/// Shows the lessons inside a single module (opened from the skill tree).
class ModuleScreen extends StatelessWidget {
  const ModuleScreen({
    super.key,
    required this.trackId,
    required this.module,
  });

  final String trackId;
  final Module module;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.track(trackId);
    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final lesson in module.lessons)
            LessonTile(trackId: trackId, lesson: lesson, accent: accent),
        ],
      ),
    );
  }
}

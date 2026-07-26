import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/curriculum_providers.dart';
import 'widgets/lesson_tile.dart';

/// Lists a track's modules and lessons as a simple scrollable catalog.
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
        data: (track) => ListView(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                LessonTile(
                    trackId: track.id, lesson: lesson, accent: accent),
            ],
          ],
        ),
      ),
    );
  }
}

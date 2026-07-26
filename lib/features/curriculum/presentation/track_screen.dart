import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
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
          return ListView.builder(
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
          );
        },
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

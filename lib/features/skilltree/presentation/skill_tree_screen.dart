import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../curriculum/application/curriculum_providers.dart';
import '../../curriculum/domain/track.dart';
import '../../curriculum/presentation/module_screen.dart';
import '../../player/application/player_controller.dart';

enum _NodeStatus { locked, unlocked, completed }

/// A vertical "skill path" of modules. A module unlocks when the previous one
/// is fully completed; progression is gated but the layout supports branching
/// modules (same-index siblings) as the curriculum grows.
class SkillTreeScreen extends ConsumerWidget {
  const SkillTreeScreen({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackProvider(trackId));
    final completed = ref.watch(
        playerControllerProvider.select((p) => p.completedLessonIds));
    final accent = AppColors.track(trackId);

    return Scaffold(
      appBar: AppBar(title: const Text('Skill Tree')),
      body: trackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (track) {
          final modules = track.modules;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: modules.length,
            itemBuilder: (context, i) {
              final module = modules[i];
              final status = _statusFor(modules, i, completed);
              final done =
                  module.lessons.where((l) => completed.contains(l.id)).length;
              return _ModuleNode(
                module: module,
                accent: accent,
                status: status,
                completedCount: done,
                isFirst: i == 0,
                isLast: i == modules.length - 1,
                onTap: status == _NodeStatus.locked
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ModuleScreen(
                                trackId: trackId, module: module),
                          ),
                        ),
              );
            },
          );
        },
      ),
    );
  }

  _NodeStatus _statusFor(
      List<Module> modules, int index, Set<String> completed) {
    bool moduleDone(Module m) =>
        m.lessons.isNotEmpty &&
        m.lessons.every((l) => completed.contains(l.id));

    if (moduleDone(modules[index])) return _NodeStatus.completed;
    if (index == 0) return _NodeStatus.unlocked;
    return moduleDone(modules[index - 1])
        ? _NodeStatus.unlocked
        : _NodeStatus.locked;
  }
}

class _ModuleNode extends StatelessWidget {
  const _ModuleNode({
    required this.module,
    required this.accent,
    required this.status,
    required this.completedCount,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final Module module;
  final Color accent;
  final _NodeStatus status;
  final int completedCount;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = status == _NodeStatus.locked;
    final completed = status == _NodeStatus.completed;
    final nodeColor = locked
        ? AppColors.outline
        : (completed ? AppColors.success : accent);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail with connector line + node dot.
          SizedBox(
            width: 64,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 3,
                    color: isFirst
                        ? Colors.transparent
                        : AppColors.outline,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: nodeColor.withOpacity(locked ? 0.15 : 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: nodeColor, width: 2),
                  ),
                  child: Icon(
                    locked
                        ? Icons.lock
                        : (completed ? Icons.check : Icons.play_arrow),
                    size: 20,
                    color: nodeColor,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 3,
                    color: isLast ? Colors.transparent : AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          // Card.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: locked ? AppColors.outline : nodeColor,
                        width: locked ? 1 : 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(module.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: locked
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          '${module.level} • $completedCount/${module.lessons.length} lessons',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

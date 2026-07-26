import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/achievement_providers.dart';
import '../domain/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(achievementStatsProvider);
    final unlocked =
        Achievement.catalog.where((a) => a.isUnlocked(stats)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('$unlocked / ${Achievement.catalog.length} unlocked',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          for (final a in Achievement.catalog)
            _AchievementCard(achievement: a, unlocked: a.isUnlocked(stats)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.unlocked});
  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.5,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (unlocked ? AppColors.success : AppColors.textMuted)
                  .withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Text(achievement.emoji,
                style: const TextStyle(fontSize: 22)),
          ),
          title: Text(achievement.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(achievement.description,
              style: const TextStyle(color: AppColors.textSecondary)),
          trailing: Icon(
            unlocked ? Icons.check_circle : Icons.lock_outline,
            color: unlocked ? AppColors.success : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

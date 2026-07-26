import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_pill.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/application/auth_controller.dart';
import '../../curriculum/presentation/track_screen.dart';
import '../../player/application/player_controller.dart';
import '../../quests/presentation/quests_screen.dart';
import '../../skilltree/presentation/skill_tree_screen.dart';
import '../../store/presentation/store_screen.dart';

/// The "Learn" dashboard.
///
/// Optimization: the screen itself watches nothing, so it never rebuilds. Each
/// dynamic region (currencies, level, track selector) is its own consumer that
/// watches only the fields it needs via `select`, so an XP or energy change
/// repaints just that region — not the whole tab, and not while another tab is
/// on screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              sliver: SliverToBoxAdapter(child: _HeaderRow()),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _LevelSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  l10n.chooseLanguage,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _TrackSelector(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.play_lesson_rounded,
                      title: l10n.continueLearning,
                      color: AppColors.primary,
                      onTap: () => _push(
                          context, (id) => TrackScreen(trackId: id)),
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.account_tree_rounded,
                      title: l10n.skillTree,
                      color: AppColors.cpp,
                      onTap: () => _push(
                          context, (id) => SkillTreeScreen(trackId: id)),
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.flag_rounded,
                      title: l10n.dailyQuests,
                      color: AppColors.success,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuestsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Demo affordance so the economy is testable.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Consumer(
                  builder: (context, ref, _) => OutlinedButton.icon(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .addXp(AppConstants.xpPerLesson),
                    icon: const Icon(Icons.add),
                    label: const Text('Demo: +20 XP'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pushes a track-scoped screen, reading the selected track lazily at build
  /// time so the dashboard doesn't rebuild when the track changes.
  void _push(BuildContext context, Widget Function(String trackId) builder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (_, ref, __) => builder(
            ref.read(playerControllerProvider).selectedTrack,
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends ConsumerWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(
        authControllerProvider.select((s) => s.user?.displayName ?? 'Coder'));
    final energy =
        ref.watch(playerControllerProvider.select((p) => p.energy));
    final crystals =
        ref.watch(playerControllerProvider.select((p) => p.crystals));

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.greeting(name),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        StatPill(
          icon: Icons.favorite,
          value: '$energy',
          color: AppColors.energy,
          onTap: () => _showEnergySheet(context, ref),
        ),
        const SizedBox(width: 8),
        StatPill(
          icon: Icons.diamond,
          value: '$crystals',
          color: AppColors.crystal,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StoreScreen()),
          ),
        ),
      ],
    );
  }
}

class _LevelSection extends ConsumerWidget {
  const _LevelSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(playerControllerProvider.select((p) => p.level));
    final progress =
        ref.watch(playerControllerProvider.select((p) => p.levelProgress));
    final xp = ref.watch(playerControllerProvider.select((p) => p.xp));
    final streak = ref.watch(playerControllerProvider.select((p) => p.streak));
    return _LevelCard(
        level: level, progress: progress, xp: xp, streak: streak);
  }
}

class _TrackSelector extends ConsumerWidget {
  const _TrackSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(playerControllerProvider.select((p) => p.selectedTrack));
    final ctrl = ref.read(playerControllerProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: _TrackCard(
            title: 'Python',
            subtitle: 'Junior → Middle+',
            color: AppColors.python,
            selected: selected == 'python',
            onTap: () => ctrl.selectTrack('python'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TrackCard(
            title: 'C++',
            subtitle: 'Junior → Middle+',
            color: AppColors.cpp,
            selected: selected == 'cpp',
            onTap: () => ctrl.selectTrack('cpp'),
          ),
        ),
      ],
    );
  }
}

void _showEnergySheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final player = ref.read(playerControllerProvider);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: AppColors.energy, size: 40),
            const SizedBox(height: 12),
            Text('${player.energy} / ${AppConstants.maxEnergy} energy',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Energy regenerates over time. Refill instantly with crystals.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.diamond, size: 18),
                label: Text(
                    'Refill for ${AppConstants.energyRefillCostCrystals} crystals'),
                onPressed: () {
                  final ok = ref
                      .read(playerControllerProvider.notifier)
                      .refillEnergyForCrystals();
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          ok ? 'Energy refilled!' : 'Not enough crystals.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.progress,
    required this.xp,
    required this.streak,
  });
  final int level;
  final double progress;
  final int xp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(0.18),
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level $level',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('$xp XP',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text('$streak',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceHigh,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.code, color: color),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

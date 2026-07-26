import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../achievements/application/achievement_providers.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../auth/application/auth_controller.dart';
import '../../crafting/application/crafting_controller.dart';
import '../../crafting/presentation/crafting_screen.dart';
import '../../player/application/player_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../store/application/store_controller.dart';
import '../../store/presentation/store_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).user;
    final player = ref.watch(playerControllerProvider);
    final avatarEmoji = ref.watch(
        craftingControllerProvider.select((s) => s.equippedAvatarEmoji));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.18),
                child: Text(
                  avatarEmoji ??
                      (user?.displayName ?? 'C').characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: avatarEmoji != null ? 34 : 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName ?? 'Coder',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  if (user?.email != null)
                    Text(user!.email!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatBox(label: l10n.xpLabel, value: '${player.xp}'),
              const SizedBox(width: 12),
              _StatBox(label: l10n.crystalsLabel, value: '${player.crystals}'),
              const SizedBox(width: 12),
              _StatBox(label: l10n.streakLabel, value: '${player.streak}'),
            ],
          ),
          const SizedBox(height: 24),
          _NavTile(
            icon: Icons.storefront_rounded,
            color: AppColors.crystal,
            title: 'Store',
            subtitle: 'Crystals & subscriptions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StoreScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.handyman_rounded,
            color: AppColors.warning,
            title: 'Crafting',
            subtitle: 'Turn parts into cosmetics',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CraftingScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.military_tech_rounded,
            color: AppColors.success,
            title: 'Achievements',
            subtitle:
                '${ref.watch(unlockedAchievementCountProvider)} unlocked',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          Consumer(builder: (context, ref, _) {
            final tier = ref.watch(
                storeControllerProvider.select((s) => s.activeTier));
            if (tier == 'none') return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Chip(
                avatar: const Icon(Icons.workspace_premium,
                    size: 18, color: AppColors.warning),
                label: Text('${tier[0].toUpperCase()}${tier.substring(1)} member'),
              ),
            );
          }),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(l10n.logOut,
                style: const TextStyle(color: AppColors.error)),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.16),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

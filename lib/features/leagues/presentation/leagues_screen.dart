import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/league_controller.dart';

/// Weekly league board (30 players ranked by XP). Currently a client-side
/// mock; real matchmaking + weekly reset run server-side on the Blaze plan.
class LeaguesScreen extends ConsumerWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final board = ref.watch(leagueBoardProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabLeagues)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bronze League',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Top 10 promote this week. Earn XP to climb!',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: board.length,
              itemBuilder: (context, i) {
                final m = board[i];
                final rank = i + 1;
                final promote = rank <= 10;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: m.isYou
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: m.isYou ? AppColors.primary : AppColors.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: promote
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.name.trim(),
                          style: TextStyle(
                            fontWeight:
                                m.isYou ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.bolt, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${m.weeklyXp}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

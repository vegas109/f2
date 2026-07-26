import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../player/application/player_controller.dart';

class LeagueMember {
  const LeagueMember({
    required this.name,
    required this.weeklyXp,
    required this.isYou,
  });
  final String name;
  final int weeklyXp;
  final bool isYou;
}

/// Builds a mock weekly league board of [AppConstants.leagueSize] players
/// ranked by XP. Bots are deterministic (fixed seed) so the board is stable
/// within a session.
///
/// The real version pairs 30 real players and resets weekly via scheduled
/// Cloud Functions (Blaze). This client-side board is a stand-in until then.
final leagueBoardProvider = Provider<List<LeagueMember>>((ref) {
  final myXp = ref.watch(playerControllerProvider.select((p) => p.xp));

  const names = [
    'Ada', 'Linus', 'Grace', 'Guido', 'Dennis', 'Bjarne', 'Ken', 'Margaret',
    'Alan', 'Barbara', 'Donald', 'Katherine', 'James', 'Radia', 'Tim',
    'Shafi', 'Leslie', 'Vint', 'Frances', 'Edsger', 'Niklaus', 'John',
    'Adele', 'Hedy', 'Anita', 'Sophie', 'Nikolai', ' Irina', 'Mila',
  ];

  final rng = Random(42);
  final members = <LeagueMember>[
    LeagueMember(name: 'You', weeklyXp: myXp, isYou: true),
    for (var i = 0; i < AppConstants.leagueSize - 1; i++)
      LeagueMember(
        name: names[i % names.length],
        weeklyXp: 20 + rng.nextInt(600),
        isYou: false,
      ),
  ]..sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

  return members;
});

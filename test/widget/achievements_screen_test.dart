import 'package:codehero/features/achievements/domain/achievement.dart';
import 'package:codehero/features/achievements/presentation/achievements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('renders every achievement, all locked for a new player',
      (tester) async {
    await pumpApp(tester, const AchievementsScreen());

    // Each achievement title from the catalog is shown.
    for (final a in Achievement.catalog) {
      expect(find.text(a.title), findsOneWidget);
    }

    // A brand-new player has nothing unlocked yet.
    expect(find.text('0 / ${Achievement.catalog.length} unlocked'),
        findsOneWidget);
    expect(find.byIcon(Icons.lock_outline),
        findsNWidgets(Achievement.catalog.length));
  });
}

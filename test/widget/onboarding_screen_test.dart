import 'package:codehero/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('onboarding advances through pages to the final CTA',
      (tester) async {
    await pumpApp(tester, const OnboardingScreen());

    // First page + a Next button.
    expect(find.text('Learn by doing'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Level up'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // Last page shows the final call to action.
    expect(find.text('Get started'), findsOneWidget);
  });
}

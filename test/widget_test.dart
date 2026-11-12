import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_care_card/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BabyCareCardApp(),
      ),
    );

    // The first-launch check is async (no saved data in tests), so let it run.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    // Verify that onboarding is shown.
    expect(find.text('Leaving your child with someone?'), findsOneWidget);
  });
}

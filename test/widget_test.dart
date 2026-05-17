// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlocal_gig/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HyperLocalGigApp());
    // Verify the onboarding screen loads
    expect(find.text('GigMap'), findsOneWidget);
  });
}

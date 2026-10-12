import 'package:flutter_test/flutter_test.dart';
import 'package:senda/main.dart';

void main() {
  testWidgets('App smoke test loads WelcomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // Welcome screen contains repeating space particles animation, so pump specific frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify WelcomeScreen text is present
    expect(find.text('Sign Up / Log In'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:senda/main.dart';
import 'package:senda/routes/app_routes.dart';
import 'package:senda/routes/app_router.dart';

void main() {
  testWidgets('GoRouter routes and ShellRoute navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Initially at welcome
    expect(find.text('Sign Up / Log In'), findsOneWidget);

    // Navigate to Auth screen via GoRouter
    appRouter.goNamed(AppRouteNames.auth);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text("Let's get you set up."), findsOneWidget);

    // Navigate to Home Shell tab 0 (Home)
    appRouter.goNamed(AppRouteNames.home, queryParameters: {'connected': 'true'});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Good morning, Collins'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget); // Bottom bar tab

    // Navigate to Shell tab 1 (Activity)
    appRouter.goNamed(AppRouteNames.activity);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Activity'), findsWidgets);

    // Navigate to Shell tab 2 (Pay)
    appRouter.goNamed(AppRouteNames.pay);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Pay'), findsWidgets);
    expect(find.text('Transfers'), findsOneWidget);

    // Navigate to Shell tab 3 (Profile)
    appRouter.goNamed(AppRouteNames.profile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Profile'), findsWidgets);

    // Navigate to Full-screen modal (Bank Transfer)
    appRouter.pushNamed(AppRouteNames.bankTransfer);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Bank Transfer'), findsWidgets);
  });
}

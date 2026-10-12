import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

/// The persistent UI Shell for the HomeScreen and its bottom navigation children
/// (Home, Activity, Pay, Profile).
class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({
    super.key,
    required this.child,
  });

  static int calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutePaths.activity)) {
      return 1;
    }
    if (location.startsWith(AppRoutePaths.pay)) {
      return 2;
    }
    if (location.startsWith(AppRoutePaths.profile)) {
      return 3;
    }
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRouteNames.home);
        break;
      case 1:
        context.goNamed(AppRouteNames.activity);
        break;
      case 2:
        context.goNamed(AppRouteNames.pay);
        break;
      case 3:
        context.goNamed(AppRouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = calculateSelectedIndex(context);

    return Scaffold(
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

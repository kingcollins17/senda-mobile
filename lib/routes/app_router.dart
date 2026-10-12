import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/wallet_state.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/wallet_connection_screen.dart';
import '../screens/home_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/pay_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/bank_transfer_screen.dart';
import '../screens/airtime_screen.dart';
import '../screens/data_screen.dart';
import '../screens/electricity_screen.dart';
import '../screens/tv_screen.dart';
import '../screens/fund_account_screen.dart';
import '../screens/payment_screen.dart';

import 'app_routes.dart';
import 'app_transitions.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

/// The main GoRouter configuration for the application.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutePaths.welcome,
  routes: [
    // Redirect root to welcome
    GoRoute(
      path: AppRoutePaths.root,
      redirect: (context, state) => AppRoutePaths.welcome,
    ),

    // Onboarding & Authentication flows
    GoRoute(
      name: AppRouteNames.welcome,
      path: AppRoutePaths.welcome,
      pageBuilder: (context, state) => AppTransitions.sharedAxisScaled(
        key: state.pageKey,
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.auth,
      path: AppRoutePaths.auth,
      pageBuilder: (context, state) => AppTransitions.sharedAxisScaled(
        key: state.pageKey,
        child: const AuthScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.walletConnection,
      path: AppRoutePaths.walletConnection,
      pageBuilder: (context, state) => AppTransitions.sharedAxisScaled(
        key: state.pageKey,
        child: const WalletConnectionScreen(),
      ),
    ),

    // Persistent Shell for HomeScreen and its tabs
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return HomeShell(child: child);
      },
      routes: [
        GoRoute(
          name: AppRouteNames.home,
          path: AppRoutePaths.home,
          pageBuilder: (context, state) {
            final queryConnected = state.uri.queryParameters['connected'];
            if (queryConnected != null) {
              WalletState.isConnected = queryConnected == 'true';
            } else if (state.extra is bool) {
              WalletState.isConnected = state.extra as bool;
            }

            return AppTransitions.fadeThrough(
              key: state.pageKey,
              child: HomeScreen(
                isWalletConnected: WalletState.isConnected,
              ),
            );
          },
        ),
        GoRoute(
          name: AppRouteNames.activity,
          path: AppRoutePaths.activity,
          pageBuilder: (context, state) => AppTransitions.fadeThrough(
            key: state.pageKey,
            child: const ActivityScreen(),
          ),
        ),
        GoRoute(
          name: AppRouteNames.pay,
          path: AppRoutePaths.pay,
          pageBuilder: (context, state) => AppTransitions.fadeThrough(
            key: state.pageKey,
            child: const PayScreen(),
          ),
        ),
        GoRoute(
          name: AppRouteNames.profile,
          path: AppRoutePaths.profile,
          pageBuilder: (context, state) => AppTransitions.fadeThrough(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),

    // Full-screen action / modal routes (outside shell to cover bottom nav bar)
    GoRoute(
      name: AppRouteNames.bankTransfer,
      path: AppRoutePaths.bankTransfer,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const BankTransferScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.airtime,
      path: AppRoutePaths.airtime,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const AirtimeScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.data,
      path: AppRoutePaths.data,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const DataScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.electricity,
      path: AppRoutePaths.electricity,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const ElectricityScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.tv,
      path: AppRoutePaths.tv,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const TvScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.fundAccount,
      path: AppRoutePaths.fundAccount,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppTransitions.slideUp(
        key: state.pageKey,
        child: const FundAccountScreen(),
      ),
    ),
    GoRoute(
      name: AppRouteNames.paymentFlow,
      path: AppRoutePaths.paymentFlow,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        String serviceName = 'Payment';
        IconData serviceIcon = Icons.payment;

        if (state.extra is PaymentFlowArgs) {
          final args = state.extra as PaymentFlowArgs;
          serviceName = args.serviceName;
          serviceIcon = args.serviceIcon;
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          serviceName = map['serviceName'] as String? ?? serviceName;
          serviceIcon = map['serviceIcon'] as IconData? ?? serviceIcon;
        } else if (state.uri.queryParameters.containsKey('serviceName')) {
          serviceName = state.uri.queryParameters['serviceName']!;
        }

        return AppTransitions.slideUp(
          key: state.pageKey,
          child: PaymentFlowScreen(
            serviceName: serviceName,
            serviceIcon: serviceIcon,
          ),
        );
      },
    ),
  ],
);

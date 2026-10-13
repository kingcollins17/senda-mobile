import 'package:flutter/material.dart';

/// Route names used throughout the Senda application for declarative navigation.
class AppRouteNames {
  AppRouteNames._();
  // Splash
  static const String splash = 'splash';

  // Root authentication & onboarding
  static const String welcome = 'welcome';
  static const String auth = 'auth';
  static const String walletConnection = 'walletConnection';

  // Shell tabs
  static const String home = 'home';
  static const String activity = 'activity';
  static const String pay = 'pay';
  static const String profile = 'profile';

  // Modal / Detail action flows
  static const String bankTransfer = 'bankTransfer';
  static const String airtime = 'airtime';
  static const String data = 'data';
  static const String electricity = 'electricity';
  static const String tv = 'tv';
  static const String fundAccount = 'fundAccount';
  static const String paymentFlow = 'paymentFlow';
}

/// URL paths for each route.
class AppRoutePaths {
  AppRoutePaths._();

  // Root authentication & onboarding
  static const String root = '/';
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String walletConnection = '/connect-wallet';

  // Shell tabs
  static const String home = '/home';
  static const String activity = '/activity';
  static const String pay = '/pay';
  static const String profile = '/profile';

  // Modal / Detail action flows
  static const String bankTransfer = '/bank-transfer';
  static const String airtime = '/airtime';
  static const String data = '/data';
  static const String electricity = '/electricity';
  static const String tv = '/tv';
  static const String fundAccount = '/fund-account';
  static const String paymentFlow = '/payment-flow';
}

/// Arguments passed to the dynamic PaymentFlowScreen.
class PaymentFlowArgs {
  final String serviceName;
  final IconData serviceIcon;

  const PaymentFlowArgs({required this.serviceName, required this.serviceIcon});
}

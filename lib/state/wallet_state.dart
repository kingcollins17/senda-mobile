import 'package:flutter/foundation.dart';

/// Global wallet connection state manager to ensure persistence
/// across tab navigation, deep links, and flow transitions.
class WalletState {
  static final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(false);

  static bool get isConnected => isConnectedNotifier.value;

  static set isConnected(bool value) {
    isConnectedNotifier.value = value;
  }

  static void connect() {
    isConnected = true;
  }

  static void disconnect() {
    isConnected = false;
  }
}

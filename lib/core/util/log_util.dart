import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:senda/core/util/json_util.dart';

extension AppLogUtil on Object {

  void debugLog(
    [DebugLevel level=DebugLevel.info]
  ) {
    if(kDebugMode) {
        debugPrint(toJsonString());
        DebugCache.instance.add(DebugData(level: level, data: this, timestamp: DateTime.now()));
    }
  }
}

enum DebugLevel {info, warn, network, error}

class DebugData {
  final DebugLevel level;
  final dynamic data;
  final DateTime timestamp;

  DebugData({required this.level, required this.data, required this.timestamp});
}

class DebugCache extends ChangeNotifier {
  // ─── Singleton ────────────────────────────────────────────────────────────

  DebugCache._();

  static final DebugCache _instance = DebugCache._();

  /// The single shared instance of [DebugCache].
  static DebugCache get instance => _instance;

  // ─── State ────────────────────────────────────────────────────────────────

  final List<DebugData> _cache = [];

  /// Read-only view of the cached debug entries.
  UnmodifiableListView<DebugData> get cache => UnmodifiableListView(_cache);

  /// Appends [value] to the cache and notifies listeners.
  void add(DebugData value) {
    _cache.add(value);
    notifyListeners();
  }

  /// Clears all cached entries and notifies listeners.
  void clear() {
    _cache.clear();
    notifyListeners();
  }
}
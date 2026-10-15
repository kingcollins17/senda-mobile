import 'dart:async';
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:senda/core/models/storage_keys.dart';

/// A strongly-typed local storage service backed by a single Hive [Box].
///
/// Each instance of [LocalStorageService] is bound to one [AppBox] opened at
/// construction time via [LocalStorageService.open].
///
/// **Setup** (call once, before creating any service instances):
/// ```dart
/// await Hive.initFlutter();
/// ```
///
/// **Create an instance:**
/// ```dart
/// final storage = await LocalStorageService.open(AppBox.app);
/// ```
///
/// **Read / write:**
/// ```dart
/// await storage.put(AppStorageKey.authToken, 'eyJ...');
/// final token = storage.get<String>(AppStorageKey.authToken);
/// await storage.delete(AppStorageKey.authToken);
///
/// // Or with any custom String key:
/// await storage.put('customKey', 'value');
/// final custom = storage.get<String>('customKey');
/// ```
class LocalStorageService {
  // ─── Internal state ────────────────────────────────────────────────────────

  final Box _box;

  /// The [AppBox] this service instance is bound to.
  final AppBox appBox;

  LocalStorageService._({required Box hiveBox, required this.appBox})
      : _box = hiveBox;

  // ─── Factory constructor ───────────────────────────────────────────────────

  /// Opens the Hive box identified by [appBox] and returns a bound service.
  ///
  /// If the box is already open, Hive returns the cached instance — no
  /// duplicate I/O is performed.
  static Future<LocalStorageService> open(AppBox appBox) async {
    final hiveBox = await Hive.openBox(appBox.name);
    return LocalStorageService._(hiveBox: hiveBox, appBox: appBox);
  }

  // ─── Core CRUD ─────────────────────────────────────────────────────────────

  /// Writes [value] under [key].
  ///
  /// Accepts any Hive-primitive (String, int, double, bool, List, Map)
  /// as well as any object that has a `toJson()` method — it will be
  /// serialised to a JSON string automatically.
  Future<void> put(String key, dynamic value) async {
    final serialised = _serialise(value);
    await _box.put(key, serialised);
  }

  /// Returns the value stored under [key], cast to [T], or null if absent.
  ///
  /// For values stored via [putObject] / objects serialised from JSON,
  /// use [getObject] instead.
  T? get<T>(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    if (raw is T) return raw;
    return null;
  }

  /// Returns the raw value under [key] without any type coercion.
  dynamic getRaw(String key) => _box.get(key);

  /// Serialises [value] via [toJson] and stores the resulting JSON string.
  ///
  /// Retrieve with [getObject].
  Future<void> putObject(String key, dynamic value) async {
    try {
      // ignore: avoid_dynamic_calls
      final json = value.toJson();
      await _box.put(key, jsonEncode(json));
    } catch (e) {
      throw ArgumentError(
        'putObject: value of type ${value.runtimeType} does not have a '
        'toJson() method. Use put() for primitives.',
      );
    }
  }

  /// Decodes the JSON string stored under [key] and passes the resulting
  /// [Map<String, dynamic>] to [fromJson].
  ///
  /// Returns null if the key is absent or the stored value is not valid JSON.
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is Map<String, dynamic>) return fromJson(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if [key] has a non-null value in this box.
  bool contains(String key) => _box.containsKey(key);

  /// Removes the value stored under [key]. No-op if the key is absent.
  Future<void> delete(String key) => _box.delete(key);

  /// Removes all entries from this box.
  Future<void> clear() => _box.clear().then((_) {});

  // ─── Reactive / Stream ─────────────────────────────────────────────────────

  /// Returns a [Stream] that emits a [BoxEvent] whenever [key] changes.
  ///
  /// Useful for listening to token refreshes, preference changes, etc.
  Stream<BoxEvent> watch(String key) =>
      _box.watch(key: key);

  /// Returns a [Stream] that emits on any change in this box.
  Stream<BoxEvent> watchAll() => _box.watch();

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Closes this box. After calling [close], the service must not be used.
  Future<void> close() => _box.close();

  /// Deletes all data from the box file on disk, then closes it.
  /// Use with extreme caution — this is irreversible.
  Future<void> destroy() => _box.deleteFromDisk();

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Converts [value] to a Hive-safe primitive.
  ///
  /// - Dart primitives and collections pass through unchanged.
  /// - Objects with `toJson()` are encoded as JSON strings.
  /// - Anything else falls back to `toString()`.
  static dynamic _serialise(dynamic value) {
    if (value == null ||
        value is bool ||
        value is int ||
        value is double ||
        value is String) {
      return value;
    }
    if (value is List || value is Map) {
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }
    try {
      // ignore: avoid_dynamic_calls
      return jsonEncode(value.toJson());
    } catch (_) {
      return value.toString();
    }
  }
}

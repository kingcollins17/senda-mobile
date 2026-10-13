import 'dart:convert';

/// A robust JSON utility extension on [Object] that safely converts any
/// Dart value to a pretty-printed JSON string.
///
/// Handles all known edge cases including:
///   - Primitive types (int, double, bool, String)
///   - null values (via extension on nullable)
///   - Map / List with arbitrarily nested content
///   - Objects with a `toJson()` method
///   - Circular / self-referencing structures
///   - Non-serialisable types (DateTime, Uri, Enum, Uint8List, etc.)
///   - Infinity / NaN double values (forbidden by JSON spec)
///   - Encoding errors and unexpected exceptions
extension ToJsonString on Object {
  // ─── private helpers ───────────────────────────────────────────────────────

  static final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  /// Recursively sanitises [value] so that [json.encode] will never throw.
  ///
  /// Conversion rules (applied in order):
  ///   1. null           → null
  ///   2. bool / int / String → as-is
  ///   3. double         → special-cases NaN and ±Infinity → null
  ///   4. Map            → recursively sanitise keys (→ String) and values
  ///   5. List / Iterable → recursively sanitise each element → List
  ///   6. has toJson()   → sanitise the result of toJson()
  ///   7. DateTime       → ISO-8601 string
  ///   8. Uri            → string representation
  ///   9. Enum (Dart 2.17+) → enum name string
  ///  10. Fallback       → toString()
  static dynamic _sanitise(dynamic value, _RefTracker refs) {
    // ── 1. null ──────────────────────────────────────────────────────────────
    if (value == null) return null;

    // ── 2. JSON primitives ────────────────────────────────────────────────
    if (value is bool) return value;
    if (value is int) return value;
    if (value is String) return value;

    // ── 3. double (guard NaN / Infinity) ─────────────────────────────────
    if (value is double) {
      if (value.isNaN || value.isInfinite) return null;
      return value;
    }

    // ── 4. Map ────────────────────────────────────────────────────────────
    if (value is Map) {
      if (refs.contains(value)) return '<circular>';
      refs.add(value);
      try {
        return Map<String, dynamic>.fromEntries(
          value.entries.map(
            (e) => MapEntry(
              e.key?.toString() ?? 'null',
              _sanitise(e.value, refs),
            ),
          ),
        );
      } finally {
        refs.remove(value);
      }
    }

    // ── 5. List / Iterable ────────────────────────────────────────────────
    if (value is Iterable) {
      if (refs.contains(value)) return '<circular>';
      refs.add(value);
      try {
        return value.map((e) => _sanitise(e, refs)).toList();
      } finally {
        refs.remove(value);
      }
    }

    // ── 6. Object with toJson() ───────────────────────────────────────────
    final dynamic dyn = value;
    try {
      // ignore: avoid_dynamic_calls
      final toJsonResult = dyn.toJson();
      // Only use if the result is actually different (avoid infinite loops
      // where toJson() returns `this`)
      if (!identical(toJsonResult, value)) {
        return _sanitise(toJsonResult, refs);
      }
    } catch (_) {
      // toJson() does not exist or threw — fall through
    }

    // ── 7. DateTime ───────────────────────────────────────────────────────
    if (value is DateTime) return value.toIso8601String();

    // ── 8. Uri ────────────────────────────────────────────────────────────
    if (value is Uri) return value.toString();

    // ── 9. Enum (Dart 2.17+ exposes .name on every enum) ─────────────────
    try {
      // ignore: avoid_dynamic_calls
      final name = dyn.name as String?;
      if (name != null) return name;
    } catch (_) {}

    // ── 10. Fallback ──────────────────────────────────────────────────────
    return value.toString();
  }

  // ─── public API ────────────────────────────────────────────────────────────

  /// Returns a pretty-printed JSON string representing this object.
  ///
  /// Never throws — any unhandled error falls back to [toString].
  String toJsonString() {
    try {
      final sanitised = _sanitise(this, _RefTracker());
      return _encoder.convert(sanitised);
    } catch (e) {
      // Last-resort fallback so callers never receive an exception.
      return toString();
    }
  }

  /// Returns the compact (single-line) JSON string for this object.
  String toCompactJsonString() {
    try {
      final sanitised = _sanitise(this, _RefTracker());
      return json.encode(sanitised);
    } catch (e) {
      return toString();
    }
  }

  /// Attempts to decode [jsonString] into a Dart object.
  ///
  /// Returns null if [jsonString] is blank or is not valid JSON.
  static dynamic tryDecode(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return null;
    try {
      return json.decode(jsonString);
    } catch (_) {
      return null;
    }
  }
}

/// Extension on nullable [Object] so callers can safely call
/// `.toJsonStringOrNull()` without a null check.
extension ToJsonStringNullable on Object? {
  /// Returns `"null"` when called on a null reference, otherwise delegates
  /// to [ToJsonString.toJsonString].
  String toJsonStringOrNull() {
    final self = this;
    if (self == null) return 'null';
    return self.toJsonString();
  }
}

// ─── Internal helper ─────────────────────────────────────────────────────────

/// Tracks object references during recursive serialisation to detect and
/// break circular references without crashing.
///
/// Uses identity comparison ([identical]) so that structurally equal but
/// distinct objects are NOT mistakenly flagged as circular.
class _RefTracker {
  final List<Object> _stack = [];

  bool contains(Object obj) => _stack.any((e) => identical(e, obj));
  void add(Object obj) => _stack.add(obj);
  void remove(Object obj) {
    final idx = _stack.lastIndexWhere((e) => identical(e, obj));
    if (idx != -1) _stack.removeAt(idx);
  }
}
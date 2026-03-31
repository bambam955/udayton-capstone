typedef JsonMap = Map<String, Object?>;

/// Normalizes loosely typed decoded JSON objects into a string-keyed map.
///
/// Dart's JSON decoder can surface maps with non-`String` key types depending
/// on how test doubles or intermediate code build the object. Converting once
/// here keeps every model parser simpler and more defensive.
JsonMap asJsonMap(Object? raw) {
  if (raw is Map<Object?, Object?>) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

/// Normalizes decoded arrays so callers can iterate without repeated casts.
List<Object?> asJsonList(Object? raw) {
  if (raw is List<Object?>) {
    return raw;
  }

  if (raw is List) {
    return raw.cast<Object?>();
  }

  throw const FormatException('Expected a JSON array.');
}

/// Reads a required-ish string field while still providing a safe fallback for
/// partial or older payloads that omit the key.
String readString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  return fallback;
}

/// Reads an optional string field without coercing non-string values.
String? readNullableString(JsonMap json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

/// Parses integer-like values from either numeric JSON or string-backed IDs.
int readInt(JsonMap json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String && value.isNotEmpty) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

/// Accepts both integer and floating-point JSON values because backend payloads
/// may come from SQL adapters that choose either representation.
double readDouble(JsonMap json, String key, {double fallback = 0}) {
  final value = json[key];
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

/// Handles boolean-ish payloads that may have passed through string encoding.
bool readBool(JsonMap json, String key, {bool fallback = false}) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  return fallback;
}

/// Returns `null` instead of throwing so model factories can decide their own
/// fallback behavior for missing or malformed timestamps.
DateTime? readDateTime(JsonMap json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  return null;
}

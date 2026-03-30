typedef JsonMap = Map<String, Object?>;

JsonMap asJsonMap(Object? raw) {
  if (raw is Map<Object?, Object?>) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

List<Object?> asJsonList(Object? raw) {
  if (raw is List<Object?>) {
    return raw;
  }

  if (raw is List) {
    return raw.cast<Object?>();
  }

  throw const FormatException('Expected a JSON array.');
}

String readString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  return fallback;
}

String? readNullableString(JsonMap json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

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

DateTime? readDateTime(JsonMap json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  return null;
}

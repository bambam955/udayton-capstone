import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_models.dart';

/// Storage contract used by the auth shell to persist and restore sessions.
abstract interface class SessionStore {
  Future<ApiSession?> read();
  Future<void> write(ApiSession session);
  Future<void> clear();
}

/// Narrow key/value abstraction so session persistence can be tested without
/// depending directly on the platform secure-storage plugin.
abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Real secure-storage adapter used in production apps.
class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }
}

/// Session store that serializes the shared `ApiSession` model into secure
/// storage.
///
/// Clearing corrupted values is intentional: a bad payload should degrade to a
/// signed-out experience instead of trapping the user behind startup errors.
class SecureSessionStore implements SessionStore {
  SecureSessionStore({
    SecureValueStore? store,
    this.storageKey = 'bizrush.api.session',
  }) : _store = store ?? FlutterSecureValueStore();

  final SecureValueStore _store;
  final String storageKey;

  @override
  Future<ApiSession?> read() async {
    final raw = await _store.read(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      return ApiSession.fromJson(decoded);
    } on FormatException {
      // Treat unreadable session payloads as signed-out state so a corrupted
      // secure-storage blob cannot block app startup forever.
      await _clearCorruptedValue();
      return null;
    } on TypeError {
      await _clearCorruptedValue();
      return null;
    }
  }

  @override
  Future<void> write(ApiSession session) {
    return _store.write(storageKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() {
    return _store.delete(storageKey);
  }

  Future<void> _clearCorruptedValue() async {
    try {
      await _store.delete(storageKey);
    } catch (_) {
      // Returning signed-out state is still better than failing app startup
      // when cleanup cannot complete immediately.
    }
  }
}

/// In-memory implementation used primarily by tests and lightweight previews.
class InMemorySessionStore implements SessionStore {
  ApiSession? _session;

  @override
  Future<ApiSession?> read() async => _session;

  @override
  Future<void> write(ApiSession session) async {
    _session = session;
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}

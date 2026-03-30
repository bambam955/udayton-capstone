import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_models.dart';

abstract interface class SessionStore {
  Future<ApiSession?> read();
  Future<void> write(ApiSession session);
  Future<void> clear();
}

abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

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

    final decoded = jsonDecode(raw);
    return ApiSession.fromJson(decoded);
  }

  @override
  Future<void> write(ApiSession session) {
    return _store.write(storageKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() {
    return _store.delete(storageKey);
  }
}

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

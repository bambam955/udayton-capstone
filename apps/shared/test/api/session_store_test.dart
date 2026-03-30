import 'package:bizrush_shared/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Session stores', () {
    test('InMemorySessionStore round-trips and clears sessions', () async {
      final store = InMemorySessionStore();
      final session = ApiSession(
        accessToken: 'token-1',
        expiresAt: DateTime.utc(2099, 1, 1),
        user: const AuthUser(
          id: 'cust-1',
          role: ApiUserRole.customer,
          email: 'customer@example.com',
        ),
      );

      expect(await store.read(), isNull);

      await store.write(session);
      expect((await store.read())?.accessToken, 'token-1');

      await store.clear();
      expect(await store.read(), isNull);
    });

    test('SecureSessionStore persists sessions in the backing store', () async {
      final values = _FakeSecureValueStore();
      final store = SecureSessionStore(store: values);
      final session = ApiSession(
        accessToken: 'token-2',
        expiresAt: DateTime.utc(2099, 2, 2),
        user: const AuthUser(
          id: 'driver-1',
          role: ApiUserRole.driver,
          email: 'driver@example.com',
        ),
      );

      await store.write(session);

      final restored = await store.read();
      expect(restored?.accessToken, 'token-2');
      expect(restored?.user.role, ApiUserRole.driver);
      expect(values.writtenKeys, contains('bizrush.api.session'));

      await store.clear();
      expect(await store.read(), isNull);
    });

    test('SecureSessionStore returns null when storage is empty', () async {
      final store = SecureSessionStore(store: _FakeSecureValueStore());
      expect(await store.read(), isNull);
    });
  });
}

// Small fake so the tests cover the JSON persistence logic without requiring
// platform secure-storage bindings.
class _FakeSecureValueStore implements SecureValueStore {
  final Map<String, String> _values = <String, String>{};
  final List<String> writtenKeys = <String>[];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    writtenKeys.add(key);
    _values[key] = value;
  }
}

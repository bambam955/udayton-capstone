import 'package:bizrush_shared/api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recording_api_client.dart';

void main() {
  group('AuthApi', () {
    test('signup stores the returned session and sends customer fields',
        () async {
      final store = InMemorySessionStore();
      final client = RecordingApiClient((request) {
        return <String, Object?>{
          'accessToken': 'signup-token',
          'expiresAt': '2099-01-01T00:00:00.000Z',
          'user': <String, Object?>{
            'id': 'cust-1',
            'role': 'customer',
            'email': 'new@example.com',
          },
        };
      });

      final api = AuthApi(client, store);
      final session = await api.signup(
        role: ApiUserRole.customer,
        email: 'new@example.com',
        password: 'secret',
        fullName: 'New Customer',
        phone: '555-5555',
      );

      expect(client.requests.single.path, '/v1/auth/signup');
      expect(
        client.requests.single.body,
        <String, Object?>{
          'role': 'customer',
          'email': 'new@example.com',
          'password': 'secret',
          'fullName': 'New Customer',
          'phone': '555-5555',
        },
      );
      expect(session.accessToken, 'signup-token');
      expect((await store.read())?.user.email, 'new@example.com');
    });

    test('login sends the requested role and persists the session', () async {
      final store = InMemorySessionStore();
      final client = RecordingApiClient((request) {
        return <String, Object?>{
          'accessToken': 'login-token',
          'expiresAt': '2099-02-01T00:00:00.000Z',
          'user': <String, Object?>{
            'id': 'driver-1',
            'role': 'driver',
            'email': 'driver@example.com',
          },
        };
      });

      final api = AuthApi(client, store);
      final session = await api.login(
        role: ApiUserRole.driver,
        email: 'driver@example.com',
        password: 'secret',
        deviceInfo: 'pixel-test',
      );

      expect(client.requests.single.path, '/v1/auth/login');
      expect(
        client.requests.single.body,
        <String, Object?>{
          'role': 'driver',
          'email': 'driver@example.com',
          'password': 'secret',
          'deviceInfo': 'pixel-test',
        },
      );
      expect(session.user.role, ApiUserRole.driver);
      expect((await store.read())?.accessToken, 'login-token');
    });

    test('me decodes the authenticated principal payload', () async {
      final api = AuthApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/auth/me');
          return <String, Object?>{
            'principal': <String, Object?>{
              'userId': 'cust-1',
              'role': 'customer',
              'sessionId': 'session-1',
            },
          };
        }),
        InMemorySessionStore(),
      );

      final principal = await api.me();

      expect(principal.userId, 'cust-1');
      expect(principal.role, ApiUserRole.customer);
      expect(principal.sessionId, 'session-1');
    });

    test('logout clears the local session even when the API fails', () async {
      final store = InMemorySessionStore();
      await store.write(
        ApiSession(
          accessToken: 'token',
          expiresAt: DateTime.utc(2099, 1, 1),
          user: const AuthUser(
            id: 'cust-1',
            role: ApiUserRole.customer,
            email: 'customer@example.com',
          ),
        ),
      );

      final api = AuthApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/auth/logout');
          throw const ApiError(kind: ApiErrorKind.server, message: 'boom');
        }),
        store,
      );

      await expectLater(
        () => api.logout(ApiUserRole.customer),
        throwsA(isA<ApiError>()),
      );
      expect(await store.read(), isNull);
    });
  });

  group('CustomerMobileApi', () {
    test('bootstrap decodes customer mobile data', () async {
      final api = CustomerMobileApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/mobile/customer/bootstrap');
          return _customerBootstrapJson();
        }),
      );

      final bootstrap = await api.bootstrap();

      expect(bootstrap.customer.id, 'cust-1');
      expect(
          bootstrap.retailers.single.locations.single.name, 'Downtown Market');
      expect(bootstrap.orders.single.itemCount, 3);
      expect(bootstrap.defaultAddressId, 'addr-1');
    });

    test('catalog sends filters and decodes product payloads', () async {
      final client = RecordingApiClient((request) => _customerCatalogJson());
      final api = CustomerMobileApi(client);

      final catalog = await api.catalog(
        retailerLocationId: 'loc-1',
        category: 'Produce',
        query: 'apple',
      );

      expect(client.requests.single.queryParameters['retailerLocationId'],
          'loc-1');
      expect(client.requests.single.queryParameters['category'], 'Produce');
      expect(client.requests.single.queryParameters['query'], 'apple');
      expect(catalog.location.retailerLocationId, 'loc-1');
      expect(catalog.products.single.name, 'Fuji Apple');
      expect(catalog.cart?.itemCount, 2);
    });

    test('connect and disconnect retailer call the expected endpoints',
        () async {
      final client = RecordingApiClient((request) {
        return <String, Object?>{
          'retailerId': 'ret-1',
          'isConnected': request.path.endsWith('/connect'),
          'connectedAt': '2099-03-01T00:00:00.000Z',
        };
      });
      final api = CustomerMobileApi(client);

      final connected = await api.connectRetailer('ret-1');
      final disconnected = await api.disconnectRetailer('ret-1');

      expect(client.requests[0].path,
          '/v1/mobile/customer/retailers/ret-1/connect');
      expect(client.requests[1].path,
          '/v1/mobile/customer/retailers/ret-1/disconnect');
      expect(connected.isConnected, isTrue);
      expect(disconnected.isConnected, isFalse);
    });

    test('cancelOrder posts to the customer cancel endpoint', () async {
      final client = RecordingApiClient((request) => <String, Object?>{
            'orderId': 'ord-1',
            'externalOrderId': 'external-1',
            'retailerId': 'ret-1',
            'retailerName': 'Fresh Market',
            'retailerLocationId': 'loc-1',
            'retailerLocationName': 'Downtown Market',
            'status': 'CANCELED',
            'placedAt': '2099-01-01T00:00:00.000Z',
            'totalCents': 4550,
            'currency': 'USD',
            'itemCount': 3,
          });
      final api = CustomerMobileApi(client);

      final order = await api.cancelOrder('ord-1');

      expect(client.requests.single.path,
          '/v1/mobile/customer/orders/ord-1/cancel');
      expect(client.requests.single.method, 'POST');
      expect(order.orderId, 'ord-1');
      expect(order.status, 'CANCELED');
    });

    test('checkout sends order input and decodes the checkout summary',
        () async {
      final client = RecordingApiClient((request) => _customerCheckoutJson());
      final api = CustomerMobileApi(client);

      final checkout = await api.checkout(
        cartId: 'cart-1',
        addressId: 'addr-1',
        deliveryNotes: 'Ring bell',
        tipCents: 500,
      );

      expect(client.requests.single.path, '/v1/mobile/customer/checkout');
      expect(
        client.requests.single.body,
        <String, Object?>{
          'cartId': 'cart-1',
          'addressId': 'addr-1',
          'deliveryNotes': 'Ring bell',
          'tipCents': 500,
        },
      );
      expect(checkout.order.orderId, 'ord-1');
      expect(checkout.pricing.totalCents, 4550);
      expect(checkout.delivery.deliveryId, 'del-1');
    });
  });

  group('DriverMobileApi', () {
    test('bootstrap decodes driver jobs and earnings summaries', () async {
      final api = DriverMobileApi(
        RecordingApiClient((request) {
          expect(request.path, '/v1/mobile/driver/bootstrap');
          return _driverBootstrapJson();
        }),
      );

      final bootstrap = await api.bootstrap();

      expect(bootstrap.driver.id, 'driver-1');
      expect(bootstrap.availableJobs.single.deliveryId, 'del-1');
      expect(bootstrap.earningsSummary.todayGrossCents, 4200);
    });

    test('delivery actions decode the nested job payload', () async {
      final client = RecordingApiClient((request) {
        return <String, Object?>{
          'job': _driverJobJson(stage: request.path.split('/').last),
        };
      });
      final api = DriverMobileApi(client);

      final accepted = await api.acceptDelivery('del-1');
      final pickedUp = await api.pickupDelivery('del-1');
      final completed = await api.completeDelivery('del-1');

      expect(
          client.requests[0].path, '/v1/mobile/driver/deliveries/del-1/accept');
      expect(
          client.requests[1].path, '/v1/mobile/driver/deliveries/del-1/pickup');
      expect(client.requests[2].path,
          '/v1/mobile/driver/deliveries/del-1/complete');
      expect(accepted.stage, 'accept');
      expect(pickedUp.stage, 'pickup');
      expect(completed.stage, 'complete');
    });
  });
}

Map<String, Object?> _customerBootstrapJson() {
  return <String, Object?>{
    'customer': <String, Object?>{
      'id': 'cust-1',
      'email': 'customer@example.com',
      'fullName': 'Test Customer',
    },
    'retailers': <Object?>[
      <String, Object?>{
        'retailerId': 'ret-1',
        'name': 'Fresh Market',
        'website': 'https://fresh.example.com',
        'isEnabled': true,
        'isConnected': true,
        'locations': <Object?>[
          <String, Object?>{
            'retailerLocationId': 'loc-1',
            'retailerId': 'ret-1',
            'externalStoreId': 'store-99',
            'name': 'Downtown Market',
            'addressLine': '100 Main St',
            'city': 'Charlotte',
            'state': 'NC',
            'postalCode': '28202',
            'country': 'US',
            'lat': 35.2271,
            'lng': -80.8431,
            'isActive': true,
          },
        ],
      },
    ],
    'addresses': <Object?>[
      <String, Object?>{
        'addressId': 'addr-1',
        'label': 'Home',
        'line1': '1 Elm St',
        'line2': null,
        'city': 'Charlotte',
        'state': 'NC',
        'postalCode': '28202',
        'country': 'US',
        'instructions': 'Front desk',
        'addressLine': '1 Elm St, Charlotte, NC 28202',
        'isDefault': true,
      },
    ],
    'carts': <Object?>[
      <String, Object?>{
        'cartId': 'cart-1',
        'retailerId': 'ret-1',
        'retailerLocationId': 'loc-1',
        'status': 'ACTIVE',
        'itemCount': 2,
        'subtotalCents': 3000,
      },
    ],
    'orders': <Object?>[
      <String, Object?>{
        'orderId': 'ord-1',
        'externalOrderId': 'external-1',
        'retailerId': 'ret-1',
        'retailerName': 'Fresh Market',
        'retailerLocationId': 'loc-1',
        'retailerLocationName': 'Downtown Market',
        'status': 'SUBMITTED',
        'placedAt': '2099-01-01T00:00:00.000Z',
        'totalCents': 4550,
        'currency': 'USD',
        'itemCount': 3,
      },
    ],
    'supportTickets': <Object?>[
      <String, Object?>{
        'ticketId': 'ticket-1',
        'orderId': 'ord-1',
        'title': 'Missing item',
        'status': 'OPEN',
        'summary': 'One apple was missing.',
      },
    ],
    'defaultAddressId': 'addr-1',
  };
}

Map<String, Object?> _customerCatalogJson() {
  return <String, Object?>{
    'location': <String, Object?>{
      'retailerLocationId': 'loc-1',
      'retailerId': 'ret-1',
      'externalStoreId': 'store-99',
      'name': 'Downtown Market',
      'addressLine': '100 Main St',
      'city': 'Charlotte',
      'state': 'NC',
      'postalCode': '28202',
      'country': 'US',
      'lat': 35.2271,
      'lng': -80.8431,
      'isActive': true,
    },
    'retailer': <String, Object?>{
      'retailerId': 'ret-1',
      'name': 'Fresh Market',
    },
    'categories': <Object?>[
      <String, Object?>{'categoryId': 'cat-1', 'name': 'Produce'},
    ],
    'products': <Object?>[
      <String, Object?>{
        'productId': 'prod-1',
        'retailerId': 'ret-1',
        'categoryId': 'cat-1',
        'categoryName': 'Produce',
        'externalSku': 'sku-1',
        'name': 'Fuji Apple',
        'description': 'Sweet and crisp',
        'imageUrl': null,
        'unitPriceCents': 250,
        'currency': 'USD',
        'isAvailable': true,
      },
    ],
    'cart': <String, Object?>{
      'cartId': 'cart-1',
      'retailerId': 'ret-1',
      'retailerLocationId': 'loc-1',
      'status': 'ACTIVE',
      'itemCount': 2,
      'subtotalCents': 500,
    },
  };
}

Map<String, Object?> _customerCheckoutJson() {
  return <String, Object?>{
    'order': <String, Object?>{
      'orderId': 'ord-1',
      'externalOrderId': 'external-1',
      'retailerId': 'ret-1',
      'retailerName': 'Fresh Market',
      'retailerLocationId': 'loc-1',
      'retailerLocationName': 'Downtown Market',
      'status': 'SUBMITTED',
      'placedAt': '2099-01-01T00:00:00.000Z',
      'totalCents': 4550,
      'currency': 'USD',
      'itemCount': 3,
    },
    'pricing': <String, Object?>{
      'subtotalCents': 3000,
      'serviceFeeCents': 250,
      'deliveryFeeCents': 400,
      'estimatedTaxCents': 400,
      'tipCents': 500,
      'totalCents': 4550,
      'currency': 'USD',
    },
    'payment': <String, Object?>{
      'paymentId': 'pay-1',
      'status': 'AUTHORIZED',
      'amountCents': 4550,
      'currency': 'USD',
    },
    'delivery': <String, Object?>{
      'deliveryId': 'del-1',
      'status': 'ASSIGNED',
      'pickupLocation': 'Downtown Market',
    },
  };
}

Map<String, Object?> _driverBootstrapJson() {
  return <String, Object?>{
    'driver': <String, Object?>{
      'id': 'driver-1',
      'email': 'driver@example.com',
      'fullName': 'Driver Test',
      'status': 'ONLINE',
    },
    'availableJobs': <Object?>[_driverJobJson(stage: 'available')],
    'activeJobs': <Object?>[_driverJobJson(stage: 'assigned')],
    'completedJobs': <Object?>[_driverJobJson(stage: 'delivered')],
    'supportTickets': <Object?>[
      <String, Object?>{
        'ticketId': 'driver-ticket-1',
        'deliveryId': 'del-1',
        'title': 'Gate code missing',
        'status': 'OPEN',
        'summary': 'Need customer gate code.',
      },
    ],
    'earningsSummary': <String, Object?>{
      'todayGrossCents': 4200,
      'tipsCents': 900,
      'bonusCents': 300,
      'nextPayoutLabel': 'Tomorrow',
    },
  };
}

Map<String, Object?> _driverJobJson({required String stage}) {
  return <String, Object?>{
    'deliveryId': 'del-1',
    'orderId': 'ord-1',
    'title': 'Fresh Market delivery',
    'pickupLocationId': 'loc-1',
    'pickupName': 'Downtown Market',
    'pickupAddressLine': '100 Main St',
    'pickupLat': 35.2271,
    'pickupLng': -80.8431,
    'dropoffName': 'Test Customer',
    'dropoffAddressLine': '1 Elm St',
    'zone': 'Uptown',
    'payoutEstimateCents': 1250,
    'distanceMiles': 4.2,
    'etaMinutes': 18,
    'stage': stage,
    'detailLines': <Object?>['3 items', 'Leave at door'],
    'basePayCents': 800,
    'tipCents': 450,
  };
}

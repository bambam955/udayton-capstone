import 'package:bizrush/main.dart';
import 'package:bizrush/config/customer_app_dependencies.dart';
import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Customer app authenticates and renders API-backed tabs', (
    WidgetTester tester,
  ) async {
    final sessionStore = InMemorySessionStore();
    final apiClient = _FakeApiClient();
    final dependencies = CustomerAppDependencies(
      authApi: AuthApi(apiClient, sessionStore),
      customerApi: CustomerMobileApi(apiClient),
      resourceApi: ResourceApi(apiClient),
    );

    Future<void> selectMainTab(int index) async {
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navBar.onDestinationSelected?.call(index);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(MyApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(
        find.text(
            'Sign in to manage orders, stores, and support from live API data.'),
        findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('customer-auth-email')), 'customer@example.com');
    await tester.enterText(
        find.byKey(const Key('customer-auth-password')), 'secret');
    await tester.tap(find.byKey(const Key('customer-auth-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-logo')), findsOneWidget);
    expect(find.byKey(const Key('main-tab-home')), findsOneWidget);
    expect(find.text('Recommended items'), findsOneWidget);
    expect(find.byKey(const Key('catalog-item-prod-1')), findsOneWidget);
    expect(find.byKey(const Key('cart-line-prod-1')), findsOneWidget);

    await selectMainTab(2);
    expect(find.byKey(const Key('main-tab-orders')), findsOneWidget);
    expect(find.byKey(const Key('order-card-ord-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();
    expect(find.text('Order details'), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-sheet-close')));
    await tester.pumpAndSettle();
    expect(find.text('Order details'), findsNothing);

    await selectMainTab(3);
    expect(find.byKey(const Key('main-tab-support')), findsOneWidget);
    expect(find.byKey(const Key('support-ticket-ticket-1')), findsOneWidget);

    await selectMainTab(4);
    expect(find.byKey(const Key('main-tab-account')), findsOneWidget);
    expect(find.text('Delivery addresses'), findsOneWidget);
    expect(find.text('Downtown Market'), findsWidgets);
  });
}

// Small fake client that mirrors the handful of routes exercised by the widget
// test so the UI can be tested without a live backend.
class _FakeApiClient implements ApiClient {
  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    final raw = switch ('${request.method} ${request.path}') {
      'POST /v1/auth/login' => <String, Object?>{
          'accessToken': 'token-1',
          'expiresAt': '2099-01-01T00:00:00.000Z',
          'user': <String, Object?>{
            'id': 'cust-1',
            'role': 'customer',
            'email': 'customer@example.com',
          },
        },
      'GET /v1/mobile/customer/bootstrap' => _bootstrapJson(),
      'GET /v1/mobile/customer/catalog' => _catalogJson(),
      'GET /v1/cart-items' => <String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'cart_item_id': 'cart-item-1',
              'cart_id': 'cart-1',
              'product_id': 'prod-1',
              'external_sku': 'sku-1',
              'name_snapshot': 'Fuji Apple',
              'unit_price_cents': 250,
              'quantity': 2,
              'substitution_allowed': true,
              'notes': null,
            },
          ],
        },
      _ => throw StateError(
          'Unexpected request: ${request.method} ${request.path}'),
    };

    final data = decoder == null ? raw as T : decoder(raw);
    return ApiResponse<T>(statusCode: 200, data: data);
  }
}

Map<String, Object?> _bootstrapJson() {
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
            'externalStoreId': 'store-1',
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
        'label': 'Primary',
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
        'subtotalCents': 500,
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
        'status': 'PLACED',
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
        'summary': 'One apple was missing from the order.',
      },
    ],
    'defaultAddressId': 'addr-1',
  };
}

Map<String, Object?> _catalogJson() {
  return <String, Object?>{
    'location': <String, Object?>{
      'retailerLocationId': 'loc-1',
      'retailerId': 'ret-1',
      'externalStoreId': 'store-1',
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

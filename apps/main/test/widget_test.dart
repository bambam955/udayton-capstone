import 'package:bizrush/main.dart';
import 'package:bizrush/config/customer_app_dependencies.dart';
import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Customer app authenticates and renders API-backed tabs', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, apiClient: _FakeApiClient());

    expect(
      find.text(
        'Sign in to manage orders, stores, and support from live API data.',
      ),
      findsOneWidget,
    );

    await _login(tester);

    expect(find.byKey(const Key('customer-logo')), findsOneWidget);
    expect(find.byKey(const Key('main-tab-home')), findsOneWidget);
    expect(find.text('Recommended items'), findsOneWidget);
    expect(find.byKey(const Key('catalog-item-prod-1')), findsOneWidget);
    expect(find.byKey(const Key('cart-line-prod-1')), findsOneWidget);

    await _selectMainTab(tester, 2);
    expect(find.byKey(const Key('main-tab-orders')), findsOneWidget);
    expect(find.byKey(const Key('order-card-ord-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();
    expect(find.text('Order details'), findsOneWidget);
    expect(
        find.byKey(const Key('order-timeline-status-hist-1')), findsOneWidget);
    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('Order submitted through checkout.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('details-sheet-close')));
    await tester.pumpAndSettle();
    expect(find.text('Order details'), findsNothing);

    await _selectMainTab(tester, 3);
    expect(find.byKey(const Key('main-tab-support')), findsOneWidget);
    expect(find.byKey(const Key('support-ticket-ticket-1')), findsOneWidget);

    await _selectMainTab(tester, 4);
    expect(find.byKey(const Key('main-tab-account')), findsOneWidget);
    expect(find.text('Delivery addresses'), findsOneWidget);
    expect(find.text('Downtown Market'), findsWidgets);
  });

  testWidgets('Customer order details show an empty timeline state', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      apiClient: _FakeApiClient(orderTimeline: const <Object?>[]),
    );

    await _login(tester);
    await _selectMainTab(tester, 2);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order-timeline-empty')), findsOneWidget);
    expect(
      find.text('No status history has been recorded for this order yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Customer order details show an error state on timeline failure',
      (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      apiClient: _FakeApiClient(
        orderTimelineError: const ApiError(
          kind: ApiErrorKind.server,
          statusCode: 500,
          message: 'boom',
        ),
      ),
    );

    await _login(tester);
    await _selectMainTab(tester, 2);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order-timeline-error')), findsOneWidget);
    expect(
      find.text('Unable to load order timeline right now.'),
      findsOneWidget,
    );
  });

  testWidgets('Customer can cancel a submitted order from details', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, apiClient: _FakeApiClient());

    await _login(tester);
    await _selectMainTab(tester, 2);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order-cancel-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('order-cancel-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('order-cancel-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Order ord-1 canceled.'), findsOneWidget);
    expect(find.text('Order details'), findsNothing);
    expect(find.text('CANCELED'), findsOneWidget);
    expect(find.text('Canceled'), findsOneWidget);
  });

  testWidgets('Customer cannot cancel an ineligible order', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      apiClient: _FakeApiClient(orderStatus: 'ASSIGNED'),
    );

    await _login(tester);
    await _selectMainTab(tester, 2);
    await tester.tap(find.byKey(const Key('order-view-ord-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order-cancel-action')), findsNothing);
  });
}

// Small fake client that mirrors the handful of routes exercised by the widget
// test so the UI can be tested without a live backend.
class _FakeApiClient implements ApiClient {
  _FakeApiClient({
    List<Object?>? orderTimeline,
    this.orderTimelineError,
    this.orderStatus = 'SUBMITTED',
  }) : _orderTimeline = List<Object?>.from(
          orderTimeline ?? _defaultOrderTimeline(),
        );

  final List<Object?> _orderTimeline;
  final Object? orderTimelineError;
  String orderStatus;

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
      'GET /v1/mobile/customer/bootstrap' =>
        _bootstrapJsonWithStatus(orderStatus),
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
      'GET /v1/order-status-history' => _orderTimelineResponse(),
      'POST /v1/mobile/customer/orders/ord-1/cancel' => _cancelOrderResponse(),
      _ => throw StateError(
          'Unexpected request: ${request.method} ${request.path}'),
    };

    final data = decoder == null ? raw as T : decoder(raw);
    return ApiResponse<T>(statusCode: 200, data: data);
  }

  Object _orderTimelineResponse() {
    if (orderTimelineError != null) {
      throw orderTimelineError!;
    }

    return <String, Object?>{
      'data': _orderTimeline,
    };
  }

  Object _cancelOrderResponse() {
    orderStatus = 'CANCELED';
    _orderTimeline.add(<String, Object?>{
      'order_status_history_id': 'hist-3',
      'order_id': 'ord-1',
      'status': 'CANCELED',
      'status_time': '2099-01-01T00:15:00.000Z',
      'note': 'Canceled by customer from mobile app.',
    });
    return <String, Object?>{
      'orderId': 'ord-1',
      'externalOrderId': 'external-1',
      'retailerId': 'ret-1',
      'retailerName': 'Fresh Market',
      'retailerLocationId': 'loc-1',
      'retailerLocationName': 'Downtown Market',
      'status': orderStatus,
      'placedAt': '2099-01-01T00:00:00.000Z',
      'totalCents': 4550,
      'currency': 'USD',
      'itemCount': 3,
    };
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required ApiClient apiClient,
}) async {
  final sessionStore = InMemorySessionStore();
  final dependencies = CustomerAppDependencies(
    authApi: AuthApi(apiClient, sessionStore),
    customerApi: CustomerMobileApi(apiClient),
    resourceApi: ResourceApi(apiClient),
  );

  await tester.pumpWidget(MyApp(dependencies: dependencies));
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('customer-auth-email')),
    'customer@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('customer-auth-password')),
    'secret',
  );
  await tester.tap(find.byKey(const Key('customer-auth-submit')));
  await tester.pumpAndSettle();
}

Future<void> _selectMainTab(WidgetTester tester, int index) async {
  final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
  navBar.onDestinationSelected?.call(index);
  await tester.pumpAndSettle();
}

Map<String, Object?> _bootstrapJson() {
  return _bootstrapJsonWithStatus('SUBMITTED');
}

Map<String, Object?> _bootstrapJsonWithStatus(String orderStatus) {
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
        'status': orderStatus,
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

List<Object?> _defaultOrderTimeline() {
  return <Object?>[
    <String, Object?>{
      'order_status_history_id': 'hist-1',
      'order_id': 'ord-1',
      'status': 'SUBMITTED',
      'status_time': '2099-01-01T00:00:00.000Z',
      'note': 'Order submitted through checkout.',
    },
  ];
}

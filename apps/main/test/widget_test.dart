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
    expect(find.byKey(const Key('edit-address-addr-1')), findsOneWidget);
    expect(find.byKey(const Key('delete-address-addr-1')), findsOneWidget);
    expect(find.byKey(const Key('account-address-addr-2')), findsOneWidget);
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

  testWidgets('Customer can edit an address and move the default badge', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, apiClient: _FakeApiClient());

    await _login(tester);
    await _openAccountTab(tester);
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('edit-address-addr-2')),
    );

    expect(find.text('Edit address'), findsOneWidget);
    expect(
      _textField(tester, 'address-label-field').controller?.text,
      'Office',
    );
    expect(
      _textField(tester, 'address-line2-field').controller?.text,
      'Suite 500',
    );

    await tester.enterText(
      find.byKey(const Key('address-line1-field')),
      '250 Pine St',
    );
    await tester.enterText(
      find.byKey(const Key('address-line2-field')),
      'Suite 700',
    );
    await tester.enterText(
      find.byKey(const Key('address-instructions-field')),
      'Ring the loading dock',
    );
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('address-default-toggle')),
    );
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('address-dialog-submit')),
    );

    expect(find.text('Address updated.'), findsOneWidget);
    expect(
        find.byKey(const Key('default-address-badge-addr-2')), findsOneWidget);
    expect(find.byKey(const Key('default-address-badge-addr-1')), findsNothing);
    expect(find.textContaining('250 Pine St'), findsOneWidget);
    expect(find.textContaining('Suite 700'), findsOneWidget);
    expect(find.text('Instructions: Ring the loading dock'), findsOneWidget);
  });

  testWidgets('Customer can delete a non-default address from the account tab',
      (WidgetTester tester) async {
    await _pumpApp(tester, apiClient: _FakeApiClient());

    await _login(tester);
    await _openAccountTab(tester);
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('delete-address-addr-2')),
    );

    expect(find.text('Delete address'), findsOneWidget);
    await tester.tap(find.byKey(const Key('address-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Address deleted.'), findsOneWidget);
    expect(find.byKey(const Key('account-address-addr-2')), findsNothing);
    expect(find.byKey(const Key('account-address-addr-1')), findsOneWidget);
  });

  testWidgets('Deleting the default address promotes the next saved address', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, apiClient: _FakeApiClient());

    await _login(tester);
    await _openAccountTab(tester);
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('delete-address-addr-1')),
    );
    await tester.tap(find.byKey(const Key('address-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-address-addr-1')), findsNothing);
    expect(find.byKey(const Key('account-address-addr-2')), findsOneWidget);
    expect(
        find.byKey(const Key('default-address-badge-addr-2')), findsOneWidget);
  });

  testWidgets('Delete failures keep the address visible and show the API error',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      apiClient: _FakeApiClient(
        undeletableAddressIds: const <String>{'addr-1'},
      ),
    );

    await _login(tester);
    await _openAccountTab(tester);
    await _tapWhenVisible(
      tester,
      find.byKey(const Key('delete-address-addr-1')),
    );
    await tester.tap(find.byKey(const Key('address-delete-confirm')));
    await tester.pumpAndSettle();

    expect(
      find.text('Address is used by an existing order.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('account-address-addr-1')), findsOneWidget);
    expect(
        find.byKey(const Key('default-address-badge-addr-1')), findsOneWidget);
    expect(find.byKey(const Key('default-address-badge-addr-2')), findsNothing);
  });
}

// Small fake client that mirrors the handful of routes exercised by the widget
// test so the UI can be tested without a live backend.
class _FakeApiClient implements ApiClient {
  _FakeApiClient({
    List<Object?>? orderTimeline,
    this.orderTimelineError,
    Set<String>? undeletableAddressIds,
    List<_FakeAddressRecord>? addresses,
  })  : orderTimeline = orderTimeline ?? _defaultOrderTimeline(),
        _undeletableAddressIds = undeletableAddressIds ?? <String>{},
        _addresses = [
          for (final address in addresses ?? _defaultAddresses())
            address.copy(),
        ] {
    _nextAddressNumber = _addresses.length + 1;
  }

  final List<Object?> orderTimeline;
  final Object? orderTimelineError;
  final Set<String> _undeletableAddressIds;
  final List<_FakeAddressRecord> _addresses;
  late int _nextAddressNumber;

  @override
  Future<ApiResponse<T>> send<T>(
    ApiRequest request, {
    ApiDecoder<T>? decoder,
  }) async {
    if (request.method == 'PATCH' &&
        request.path.startsWith('/v1/addresses/')) {
      final raw = _updateAddress(
        request.path.split('/').last,
        Map<String, Object?>.from(request.body! as Map<Object?, Object?>),
      );
      final data = decoder == null ? raw as T : decoder(raw);
      return ApiResponse<T>(statusCode: 200, data: data);
    }

    if (request.method == 'DELETE' &&
        request.path.startsWith('/v1/addresses/')) {
      _deleteAddress(request.path.split('/').last);
      final data = decoder == null ? null as T : decoder(null);
      return ApiResponse<T>(statusCode: 200, data: data);
    }

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
      'GET /v1/mobile/customer/bootstrap' => _bootstrapJson(
          addresses: [
            for (final address in _sortedAddresses()) address.toBootstrapJson(),
          ],
        ),
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
      'POST /v1/addresses' => _createAddress(
          Map<String, Object?>.from(request.body! as Map<Object?, Object?>),
        ),
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
      'data': orderTimeline,
    };
  }

  Object _createAddress(Map<String, Object?> body) {
    final nextAddressNumber = _nextAddressNumber++;
    final address = _FakeAddressRecord(
      id: 'addr-$nextAddressNumber',
      label: body['label'] as String? ?? 'Address',
      line1: body['line1'] as String? ?? '',
      line2: body['line2'] as String? ?? '',
      city: body['city'] as String? ?? '',
      state: body['state'] as String? ?? '',
      postalCode: body['postal_code'] as String? ?? '',
      country: body['country'] as String? ?? 'US',
      instructions: body['instructions'] as String? ?? '',
      isDefault: body['is_default'] as bool? ?? false,
      createdOrder: nextAddressNumber,
    );
    _addresses.add(address);
    return <String, Object?>{
      'data': address.toResourceJson(),
    };
  }

  Object _updateAddress(String addressId, Map<String, Object?> body) {
    final address = _addresses.firstWhere((entry) => entry.id == addressId);
    address.applyPatch(body);
    return <String, Object?>{
      'data': address.toResourceJson(),
    };
  }

  void _deleteAddress(String addressId) {
    if (_undeletableAddressIds.contains(addressId)) {
      throw const ApiError(
        kind: ApiErrorKind.server,
        statusCode: 409,
        message: 'Address is used by an existing order.',
      );
    }

    _addresses.removeWhere((address) => address.id == addressId);
  }

  List<_FakeAddressRecord> _sortedAddresses() {
    final addresses = <_FakeAddressRecord>[..._addresses];
    addresses.sort((left, right) {
      if (left.isDefault != right.isDefault) {
        return left.isDefault ? -1 : 1;
      }
      return right.createdOrder.compareTo(left.createdOrder);
    });
    return addresses;
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

Future<void> _openAccountTab(WidgetTester tester) {
  return _selectMainTab(tester, 4);
}

Future<void> _tapWhenVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

TextField _textField(WidgetTester tester, String key) {
  return tester.widget<TextField>(find.byKey(Key(key)));
}

Map<String, Object?> _bootstrapJson({
  required List<Map<String, Object?>> addresses,
}) {
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
    'addresses': addresses,
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
    'defaultAddressId': addresses.cast<Map<String, Object?>>().firstWhere(
          (address) => address['isDefault'] == true,
          orElse: () => const <String, Object?>{},
        )['addressId'],
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
    <String, Object?>{
      'order_status_history_id': 'hist-2',
      'order_id': 'ord-1',
      'status': 'ASSIGNED',
      'status_time': '2099-01-01T00:10:00.000Z',
      'note': 'Driver assigned.',
    },
  ];
}

List<_FakeAddressRecord> _defaultAddresses() {
  return <_FakeAddressRecord>[
    _FakeAddressRecord(
      id: 'addr-1',
      label: 'Primary',
      line1: '1 Elm St',
      line2: '',
      city: 'Charlotte',
      state: 'NC',
      postalCode: '28202',
      country: 'US',
      instructions: 'Front desk',
      isDefault: true,
      createdOrder: 1,
    ),
    _FakeAddressRecord(
      id: 'addr-2',
      label: 'Office',
      line1: '200 Pine St',
      line2: 'Suite 500',
      city: 'Charlotte',
      state: 'NC',
      postalCode: '28203',
      country: 'US',
      instructions: '',
      isDefault: false,
      createdOrder: 2,
    ),
  ];
}

class _FakeAddressRecord {
  _FakeAddressRecord({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.instructions,
    required this.isDefault,
    required this.createdOrder,
  });

  final String id;
  String label;
  String line1;
  String line2;
  String city;
  String state;
  String postalCode;
  String country;
  String instructions;
  bool isDefault;
  final int createdOrder;

  _FakeAddressRecord copy() {
    return _FakeAddressRecord(
      id: id,
      label: label,
      line1: line1,
      line2: line2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      instructions: instructions,
      isDefault: isDefault,
      createdOrder: createdOrder,
    );
  }

  void applyPatch(Map<String, Object?> body) {
    if (body.containsKey('label')) {
      label = body['label'] as String? ?? '';
    }
    if (body.containsKey('line1')) {
      line1 = body['line1'] as String? ?? '';
    }
    if (body.containsKey('line2')) {
      line2 = body['line2'] as String? ?? '';
    }
    if (body.containsKey('city')) {
      city = body['city'] as String? ?? '';
    }
    if (body.containsKey('state')) {
      state = body['state'] as String? ?? '';
    }
    if (body.containsKey('postal_code')) {
      postalCode = body['postal_code'] as String? ?? '';
    }
    if (body.containsKey('country')) {
      country = body['country'] as String? ?? '';
    }
    if (body.containsKey('instructions')) {
      instructions = body['instructions'] as String? ?? '';
    }
    if (body.containsKey('is_default')) {
      isDefault = body['is_default'] as bool? ?? false;
    }
  }

  Map<String, Object?> toBootstrapJson() {
    return <String, Object?>{
      'addressId': id,
      'label': label,
      'line1': line1,
      'line2': line2.isEmpty ? null : line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'instructions': instructions.isEmpty ? null : instructions,
      'addressLine': _addressLine,
      'isDefault': isDefault,
    };
  }

  Map<String, Object?> toResourceJson() {
    return <String, Object?>{
      'address_id': id,
      'customer_id': 'cust-1',
      'label': label,
      'line1': line1,
      'line2': line2.isEmpty ? null : line2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'instructions': instructions.isEmpty ? null : instructions,
      'is_default': isDefault,
    };
  }

  String get _addressLine {
    return <String>[
      line1,
      if (line2.isNotEmpty) line2,
      city,
      state,
      postalCode,
    ].where((part) => part.isNotEmpty).join(', ');
  }
}

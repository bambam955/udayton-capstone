import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../widgets/customer_top_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import 'customer_home_models.dart';
import 'customer_order_details_sheet.dart';
import 'tabs/customer_tab_account.dart';
import 'tabs/customer_tab_home.dart';
import 'tabs/customer_tab_orders.dart';
import 'tabs/customer_tab_search.dart';
import 'tabs/customer_tab_support.dart';

// Keep transient customer messages brief so repeated cart actions do not cover
// important bottom-of-screen controls like checkout for the default 4 seconds.
const Duration _customerSnackBarDuration = Duration(milliseconds: 1500);

/// Owns state coordination for customer home tabs and API-backed actions.
class CustomerHomeShell extends StatefulWidget {
  const CustomerHomeShell({
    super.key,
    required this.session,
    required this.authApi,
    required this.customerApi,
    required this.resourceApi,
    required this.onSignedOut,
  });

  final ApiSession session;
  final AuthApi authApi;
  final CustomerMobileApi customerApi;
  final ResourceApi resourceApi;
  final VoidCallback onSignedOut;

  @override
  State<CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<CustomerHomeShell> {
  CustomerBootstrap? _bootstrap;
  CustomerCatalog? _selectedCatalog;
  List<ResourceCartItem> _cartItems = <ResourceCartItem>[];
  String? _selectedStoreId;
  String _selectedCatalogCategory = 'All';
  String _catalogSearchQuery = '';
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  bool _isMutating = false;
  bool _isSubmittingSupport = false;
  String? _cancelingOrderId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refreshBootstrap();
  }

  // Store options are derived from the bootstrap payload so the rest of the
  // shell can work with a compact, location-centric view model.
  List<StoreOption> get _stores => _storeOptionsFromBootstrap(_bootstrap);

  List<CatalogItem> get _catalogItems {
    final catalog = _selectedCatalog;
    if (catalog == null) {
      return const <CatalogItem>[];
    }

    // Product cards need display-oriented fields such as gradients and badge
    // text that are not part of the raw API model.
    return <CatalogItem>[
      for (final product in catalog.products)
        CatalogItem(
          id: product.productId,
          name: product.name,
          category: product.categoryName,
          description: product.description,
          externalSku: product.externalSku,
          unitPriceCents: product.unitPriceCents,
          badgeText: product.isAvailable ? 'Available' : 'Unavailable',
          gradient: _gradientForSeed(product.productId),
          isAvailable: product.isAvailable,
        ),
    ];
  }

  List<String> get _catalogCategories {
    final categories = <String>{'All'};
    final catalog = _selectedCatalog;
    if (catalog == null) {
      return const <String>['All'];
    }

    for (final category in catalog.categories) {
      categories.add(category.name);
    }

    return categories.toList(growable: false);
  }

  List<CatalogItem> get _visibleCatalogItems {
    // Filtering happens locally once the catalog is loaded so category and text
    // searches feel instant while the user explores the selected store.
    final query = _catalogSearchQuery.trim().toLowerCase();
    return _catalogItems.where((item) {
      final matchesCategory = _selectedCatalogCategory == 'All' ||
          item.category == _selectedCatalogCategory;
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  List<CatalogItem> get _homePreviewItems =>
      _catalogItems.take(3).toList(growable: false);

  List<CartLine> get _cartLines {
    final catalogByProductId = <String, CatalogItem>{
      for (final item in _catalogItems) item.id: item,
    };

    return <CartLine>[
      for (final cartItem in _cartItems)
        // Prefer catalog-backed display data so the cart UI stays aligned with
        // authoritative product metadata after raw snapshot writes are removed.
        CartLine(
          cartItemId: cartItem.cartItemId,
          productId: cartItem.productId,
          name: catalogByProductId[cartItem.productId]?.name ??
              cartItem.nameSnapshot ??
              'Item',
          unitPriceCents:
              catalogByProductId[cartItem.productId]?.unitPriceCents ??
                  cartItem.unitPriceCents,
          quantity: cartItem.quantity,
        ),
    ];
  }

  List<OrderPreview> get _orders {
    final bootstrap = _bootstrap;
    if (bootstrap == null) {
      return const <OrderPreview>[];
    }

    return <OrderPreview>[
      for (final order in bootstrap.orders)
        OrderPreview(
          id: order.orderId,
          retailerName: order.retailerName,
          storeName: order.retailerLocationName,
          status: order.status ?? 'UNKNOWN',
          etaText: _orderEtaText(order),
          totalCents: order.totalCents,
          itemCount: order.itemCount,
        ),
    ];
  }

  List<SupportTicket> get _supportTickets {
    final bootstrap = _bootstrap;
    if (bootstrap == null) {
      return const <SupportTicket>[];
    }

    return <SupportTicket>[
      for (final ticket in bootstrap.supportTickets)
        SupportTicket(
          id: ticket.ticketId,
          title: ticket.title,
          status: ticket.status ?? 'open',
          summary: ticket.summary,
        ),
    ];
  }

  CustomerAccountOverview get _accountOverview {
    // The account tab needs a blended view across profile, stores, orders, and
    // addresses, so package that once here instead of rebuilding it in widgets.
    final bootstrap = _bootstrap;
    final customerName = bootstrap?.customer.fullName?.trim();
    final customerEmail = bootstrap?.customer.email?.trim();
    final connectedStores = _stores.where((store) => store.isConnected).length;
    final addresses = <AddressPreview>[
      if (bootstrap != null)
        for (final address in bootstrap.addresses)
          AddressPreview(
            id: address.addressId,
            label: address.label?.trim().isEmpty ?? true
                ? 'Address'
                : address.label!.trim(),
            line1: address.line1?.trim() ?? '',
            line2: address.line2?.trim() ?? '',
            city: address.city?.trim() ?? '',
            state: address.state?.trim() ?? '',
            postalCode: address.postalCode?.trim() ?? '',
            country: address.country?.trim().isEmpty ?? true
                ? 'US'
                : address.country!.trim(),
            instructions: address.instructions?.trim() ?? '',
            addressLine: address.addressLine,
            isDefault: address.isDefault,
          ),
    ];

    return CustomerAccountOverview(
      customerName: customerName == null || customerName.isEmpty
          ? 'BizRush Customer'
          : customerName,
      customerEmail: customerEmail == null || customerEmail.isEmpty
          ? widget.session.user.email
          : customerEmail,
      connectedStoreCount: connectedStores,
      trackedOrderCount: _orders.length,
      addresses: addresses,
      stores: _stores,
    );
  }

  int get _subtotalCents {
    return _cartLines.fold<int>(
      0,
      (sum, line) => sum + (line.unitPriceCents * line.quantity),
    );
  }

  int get _serviceFeeCents {
    if (_cartLines.isEmpty) {
      return 0;
    }

    final estimated = (_subtotalCents * 0.06).round();
    return estimated.clamp(199, 1200);
  }

  int get _deliveryFeeCents => _cartLines.isEmpty ? 0 : 499;

  int get _estimatedTaxCents =>
      _cartLines.isEmpty ? 0 : (_subtotalCents * 0.045).round();

  int get _totalCents =>
      _subtotalCents +
      _serviceFeeCents +
      _deliveryFeeCents +
      _estimatedTaxCents;

  Future<void> _refreshBootstrap() async {
    final preferredStoreId = _selectedStoreId;

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // Bootstrap is the source of truth for the customer's overall account
      // state. Catalog and cart items are then loaded for the currently chosen
      // store so the shell can land in a fully rendered state.
      final bootstrap = await widget.customerApi.bootstrap();
      final stores = _storeOptionsFromBootstrap(bootstrap);
      final nextStoreId = _resolveSelectedStoreId(stores, preferredStoreId);
      final catalog = nextStoreId == null
          ? null
          : await widget.customerApi.catalog(retailerLocationId: nextStoreId);
      final cartItems = await _loadCartItems(bootstrap, nextStoreId);

      if (!mounted) {
        return;
      }

      final categories = <String>{'All'};
      if (catalog != null) {
        for (final category in catalog.categories) {
          categories.add(category.name);
        }
      }

      setState(() {
        _bootstrap = bootstrap;
        _selectedStoreId = nextStoreId;
        _selectedCatalog = catalog;
        _cartItems = cartItems;
        if (!categories.contains(_selectedCatalogCategory)) {
          _selectedCatalogCategory = 'All';
        }
        _isLoading = false;
      });
    } on ApiError catch (error) {
      await _handleApiError(
        error,
        fallbackMessage: 'Unable to load account data.',
        setLoadError: true,
      );
    }
  }

  Future<void> _onStoreSelected(String storeId) async {
    setState(() {
      _selectedStoreId = storeId;
      _selectedCatalogCategory = 'All';
      _catalogSearchQuery = '';
      _isLoading = true;
      _loadError = null;
    });

    try {
      // Changing stores swaps both the catalog and the active cart context.
      final catalog =
          await widget.customerApi.catalog(retailerLocationId: storeId);
      final cartItems = await _loadCartItems(_bootstrap, storeId);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCatalog = catalog;
        _cartItems = cartItems;
        _isLoading = false;
      });
    } on ApiError catch (error) {
      await _handleApiError(
        error,
        fallbackMessage: 'Unable to load store data.',
        setLoadError: true,
      );
    }
  }

  Future<List<ResourceCartItem>> _loadCartItems(
    CustomerBootstrap? bootstrap,
    String? retailerLocationId,
  ) async {
    if (bootstrap == null || retailerLocationId == null) {
      return const <ResourceCartItem>[];
    }

    final cart = _activeCartForStore(bootstrap, retailerLocationId);
    if (cart == null) {
      return const <ResourceCartItem>[];
    }

    // Cart items are fetched from the generic resource API because the mobile
    // bootstrap exposes only cart-level summaries.
    return widget.resourceApi.list<ResourceCartItem>(
      '/v1/cart-items',
      ResourceCartItem.fromJson,
      queryParameters: <String, String>{
        'cart_id': cart.cartId,
        'limit': '100',
      },
    );
  }

  CustomerCartSummary? _activeCartForStore(
    CustomerBootstrap bootstrap,
    String retailerLocationId,
  ) {
    // Ignore checked-out carts so the UI only manipulates the still-editable
    // cart tied to the current store.
    for (final cart in bootstrap.carts) {
      if (cart.retailerLocationId == retailerLocationId &&
          cart.status != 'CHECKED_OUT') {
        return cart;
      }
    }

    return null;
  }

  Future<String> _ensureActiveCart(CustomerCatalog catalog) async {
    final bootstrap = _bootstrap;
    if (bootstrap != null) {
      final existing =
          _activeCartForStore(bootstrap, catalog.location.retailerLocationId);
      if (existing != null) {
        return existing.cartId;
      }
    }

    // Carts are created lazily the first time the user adds an item from a
    // store, which keeps bootstrap payloads smaller for browsing-only sessions.
    final created = await widget.resourceApi.create<ResourceCart>(
      '/v1/carts',
      <String, Object?>{
        'retailer_id': catalog.retailerId,
        'retailer_location_id': catalog.location.retailerLocationId,
      },
      ResourceCart.fromJson,
    );

    return created.cartId;
  }

  Future<void> _addToCart(CatalogItem item) async {
    final catalog = _selectedCatalog;
    final selectedStore = _selectedStoreOption;
    if (catalog == null || selectedStore == null) {
      return;
    }

    if (!selectedStore.isConnected) {
      // Store connections are a prerequisite for checkout, so redirect the user
      // toward the account tab instead of silently failing.
      setState(() {
        _selectedNavIndex = 4;
      });
      _showMessage(
          'Connect ${selectedStore.name} in Account before adding items.');
      return;
    }

    setState(() {
      _isMutating = true;
    });

    try {
      final cartId = await _ensureActiveCart(catalog);
      ResourceCartItem? existingItem;
      for (final cartItem in _cartItems) {
        if (cartItem.productId == item.id) {
          existingItem = cartItem;
          break;
        }
      }

      if (existingItem == null) {
        // Create the initial line when the item has not yet been added.
        await widget.resourceApi.create<ResourceCartItem>(
          '/v1/cart-items',
          <String, Object?>{
            'cart_id': cartId,
            'product_id': item.id,
            'quantity': 1,
            'substitution_allowed': true,
          },
          ResourceCartItem.fromJson,
        );
      } else {
        // Otherwise update quantity in place to preserve one cart row per
        // product and keep the cart UI stable.
        await widget.resourceApi.update<ResourceCartItem>(
          '/v1/cart-items/${existingItem.cartItemId}',
          <String, Object?>{
            'quantity': existingItem.quantity + 1,
          },
          ResourceCartItem.fromJson,
        );
      }

      await _refreshBootstrap();
      _showMessage('${item.name} added to cart.');
    } on ApiError catch (error) {
      await _handleApiError(error, fallbackMessage: 'Unable to update cart.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _increaseQty(CartLine line) async {
    await _updateCartQuantity(line, line.quantity + 1);
  }

  Future<void> _decreaseQty(CartLine line) async {
    await _updateCartQuantity(line, line.quantity - 1);
  }

  Future<void> _removeFromCart(CartLine line) async {
    setState(() {
      _isMutating = true;
    });

    try {
      await widget.resourceApi.delete('/v1/cart-items/${line.cartItemId}');
      await _refreshBootstrap();
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to remove cart item.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _updateCartQuantity(CartLine line, int nextQuantity) async {
    setState(() {
      _isMutating = true;
    });

    try {
      if (nextQuantity <= 0) {
        // Removing the row entirely keeps the resource table aligned with the
        // user's visible cart instead of storing zero-quantity items.
        await widget.resourceApi.delete('/v1/cart-items/${line.cartItemId}');
      } else {
        await widget.resourceApi.update<ResourceCartItem>(
          '/v1/cart-items/${line.cartItemId}',
          <String, Object?>{
            'quantity': nextQuantity,
          },
          ResourceCartItem.fromJson,
        );
      }

      await _refreshBootstrap();
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to update cart quantity.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _clearCart() async {
    setState(() {
      _isMutating = true;
    });

    try {
      for (final line in _cartLines) {
        await widget.resourceApi.delete('/v1/cart-items/${line.cartItemId}');
      }
      await _refreshBootstrap();
    } on ApiError catch (error) {
      await _handleApiError(error, fallbackMessage: 'Unable to clear cart.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _checkout() async {
    final bootstrap = _bootstrap;
    final selectedStoreId = _selectedStoreId;
    if (bootstrap == null || selectedStoreId == null) {
      return;
    }

    final cart = _activeCartForStore(bootstrap, selectedStoreId);
    if (cart == null) {
      _showMessage('Add items to the cart before checking out.');
      return;
    }

    final addressId = bootstrap.defaultAddressId ??
        (bootstrap.addresses.isEmpty
            ? null
            : bootstrap.addresses.first.addressId);
    if (addressId == null) {
      // Checkout requires an address, so move the user to the account tab where
      // address creation lives.
      setState(() {
        _selectedNavIndex = 4;
      });
      _showMessage('Add a delivery address in Account before checking out.');
      return;
    }

    setState(() {
      _isMutating = true;
    });

    try {
      // The mobile checkout endpoint performs the multi-table transaction on
      // the backend and returns a ready-to-display confirmation payload.
      final checkout = await widget.customerApi.checkout(
        cartId: cart.cartId,
        addressId: addressId,
        tipCents: 0,
      );
      await _refreshBootstrap();
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedNavIndex = 2;
      });
      _showMessage('Order ${checkout.order.orderId} placed successfully.');
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to complete checkout.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _createSupportTicket(String issueType) async {
    setState(() {
      _isSubmittingSupport = true;
    });

    try {
      // Link support to the most recent order when available so the admin view
      // has context immediately.
      final orderId = _orders.isEmpty ? null : _orders.first.id;
      await widget.resourceApi.create<ResourceSupportTicket>(
        '/v1/support-tickets',
        <String, Object?>{
          if (orderId != null) 'order_id': orderId,
          'issue_type': issueType,
          'message': _supportMessageForIssue(issueType),
        },
        ResourceSupportTicket.fromJson,
      );
      await _refreshBootstrap();
      _showMessage('Support ticket created.');
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to create support ticket.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSupport = false;
        });
      }
    }
  }

  Future<void> _toggleRetailerConnection(StoreOption store) async {
    setState(() {
      _isMutating = true;
    });

    try {
      if (store.isConnected) {
        await widget.customerApi.disconnectRetailer(store.retailerId);
      } else {
        await widget.customerApi.connectRetailer(store.retailerId);
      }
      await _refreshBootstrap();
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to update store connection.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _showAddAddressDialog() async {
    final input = await _showAddressDialog();
    if (input == null) {
      return;
    }

    await _saveAddress(input: input);
  }

  Future<void> _showEditAddressDialog(AddressPreview address) async {
    final input = await _showAddressDialog(initialAddress: address);
    if (input == null) {
      return;
    }

    await _saveAddress(input: input, existingAddress: address);
  }

  Future<void> _showDeleteAddressDialog(AddressPreview address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address'),
        content: Text(
          'Delete ${address.label}?\n\n${address.addressLine}',
        ),
        actions: [
          TextButton(
            key: const Key('address-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('address-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await _deleteAddress(address);
  }

  Future<_AddressInput?> _showAddressDialog({
    AddressPreview? initialAddress,
  }) {
    return showDialog<_AddressInput>(
      context: context,
      builder: (context) => _AddressDialog(initialAddress: initialAddress),
    );
  }

  Future<void> _saveAddress({
    required _AddressInput input,
    AddressPreview? existingAddress,
  }) async {
    setState(() {
      _isMutating = true;
    });

    final previousDefault = input.isDefault
        ? _currentDefaultAddress(excludingId: existingAddress?.id)
        : null;
    var didMutateData = false;

    try {
      if (existingAddress == null) {
        // Address creation goes through the generic resource API because the
        // mobile backend only consumes the resulting address IDs.
        await widget.resourceApi.create<ResourceAddress>(
          '/v1/addresses',
          _buildAddressPayload(input),
          ResourceAddress.fromJson,
        );
      } else {
        await widget.resourceApi.update<ResourceAddress>(
          '/v1/addresses/${existingAddress.id}',
          _buildAddressPayload(input),
          ResourceAddress.fromJson,
        );
      }
      didMutateData = true;

      if (previousDefault != null) {
        await _setAddressDefault(previousDefault.id, false);
      }

      await _refreshBootstrap();
      _showMessage(
          existingAddress == null ? 'Address saved.' : 'Address updated.');
    } on ApiError catch (error) {
      if (didMutateData) {
        await _refreshBootstrap();
      }
      await _handleApiError(error, fallbackMessage: 'Unable to save address.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _deleteAddress(AddressPreview address) async {
    setState(() {
      _isMutating = true;
    });

    final fallbackDefault =
        address.isDefault ? _nextAddressCandidateAfterDelete(address.id) : null;
    var didDelete = false;

    try {
      await widget.resourceApi.delete('/v1/addresses/${address.id}');
      didDelete = true;

      if (fallbackDefault != null) {
        await _setAddressDefault(fallbackDefault.id, true);
      }

      await _refreshBootstrap();
      _showMessage('Address deleted.');
    } on ApiError catch (error) {
      if (didDelete) {
        await _refreshBootstrap();
      }
      await _handleApiError(error,
          fallbackMessage: 'Unable to delete address.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Map<String, Object?> _buildAddressPayload(_AddressInput input) {
    return <String, Object?>{
      'label': input.label,
      'line1': input.line1,
      'line2': input.line2.isEmpty ? null : input.line2,
      'city': input.city,
      'state': input.state,
      'postal_code': input.postalCode,
      'country': input.country,
      'instructions': input.instructions.isEmpty ? null : input.instructions,
      'is_default': input.isDefault,
    };
  }

  AddressPreview? _currentDefaultAddress({String? excludingId}) {
    for (final address in _accountOverview.addresses) {
      if (address.isDefault && address.id != excludingId) {
        return address;
      }
    }
    return null;
  }

  AddressPreview? _nextAddressCandidateAfterDelete(String deletedAddressId) {
    for (final address in _accountOverview.addresses) {
      if (address.id != deletedAddressId) {
        return address;
      }
    }
    return null;
  }

  Future<void> _setAddressDefault(String addressId, bool isDefault) async {
    await widget.resourceApi.update<ResourceAddress>(
      '/v1/addresses/$addressId',
      <String, Object?>{'is_default': isDefault},
      ResourceAddress.fromJson,
    );
  }

  Future<void> _onProfileAction(String action) async {
    switch (action) {
      case 'view_account':
        setState(() {
          _selectedNavIndex = 4;
        });
      case 'sign_out':
        // Sign-out is best effort on the network side, but the local shell
        // should always transition back to auth.
        await widget.authApi
            .logout(widget.session.user.role)
            .catchError((_) {});
        if (!mounted) {
          return;
        }
        widget.onSignedOut();
    }
  }

  Future<void> _handleApiError(
    ApiError error, {
    required String fallbackMessage,
    bool setLoadError = false,
  }) async {
    if (error.kind == ApiErrorKind.unauthorized) {
      await widget.authApi.logout(widget.session.user.role).catchError((_) {});
      if (mounted) {
        widget.onSignedOut();
      }
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      if (setLoadError) {
        _loadError = error.message.isEmpty ? fallbackMessage : error.message;
      }
    });
    _showMessage(error.message.isEmpty ? fallbackMessage : error.message);
  }

  void _showMessage(String message) {
    // Drop queued messages so rapid cart taps keep only the latest feedback
    // visible instead of making the checkout area wait through old snackbars.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: _customerSnackBarDuration,
          content: Text(message),
        ),
      );
  }

  void _showOrderDetails(OrderPreview order) {
    // The detail sheet loads its timeline lazily to avoid making bootstrap even
    // larger just for a screen the user may never open.
    showCustomerOrderDetailsSheet(
      context: context,
      order: order,
      loadTimeline: _loadOrderTimeline,
      orderStatusTone: _orderStatusTone,
      formatPrice: _formatPrice,
      canCancel: _canCancelOrder(order),
      isBusy: _cancelingOrderId == order.id,
      onCancel: () => _cancelOrder(order),
    );
  }

  bool _canCancelOrder(OrderPreview order) {
    return order.status.toUpperCase() == 'SUBMITTED';
  }

  Future<bool> _cancelOrder(OrderPreview order) async {
    if (_cancelingOrderId != null) {
      return false;
    }

    setState(() {
      _cancelingOrderId = order.id;
    });

    try {
      await widget.customerApi.cancelOrder(order.id);
      await _refreshBootstrap();
      if (!mounted) {
        return false;
      }

      _showMessage('Order ${order.id} canceled.');
      return true;
    } on ApiError catch (error) {
      await _handleApiError(error, fallbackMessage: 'Unable to cancel order.');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _cancelingOrderId = null;
        });
      }
    }
  }

  Future<List<OrderTimelineEntry>> _loadOrderTimeline(String orderId) async {
    final history = await widget.resourceApi.list<ResourceOrderStatusHistory>(
      '/v1/order-status-history',
      ResourceOrderStatusHistory.fromJson,
      queryParameters: <String, String>{
        'order_id': orderId,
        'limit': '100',
      },
    );

    final entries = <OrderTimelineEntry>[
      for (final item in history)
        OrderTimelineEntry(
          id: item.orderStatusHistoryId,
          status: item.status ?? 'UNKNOWN',
          occurredAt: item.statusTime,
          note: item.note,
        ),
    ];

    // The resource API does not expose server-side ordering controls, so the
    // client makes the timeline deterministic before rendering it.
    entries.sort((left, right) {
      final leftTime = left.occurredAt;
      final rightTime = right.occurredAt;
      if (leftTime == null && rightTime == null) {
        return left.status.compareTo(right.status);
      }
      if (leftTime == null) {
        return -1;
      }
      if (rightTime == null) {
        return 1;
      }
      return leftTime.compareTo(rightTime);
    });

    return entries;
  }

  static StatusBadgeTone _orderStatusTone(String status) {
    final normalized = status.toUpperCase();
    if (normalized.contains('CANCEL')) {
      return StatusBadgeTone.neutral;
    }
    if (normalized.contains('PICKING') || normalized.contains('SUBMITTED')) {
      return StatusBadgeTone.info;
    }
    if (normalized.contains('READY')) {
      return StatusBadgeTone.warning;
    }
    if (normalized.contains('OUT_FOR_DELIVERY') ||
        normalized.contains('DELIVERED')) {
      return StatusBadgeTone.success;
    }
    return StatusBadgeTone.neutral;
  }

  static StatusBadgeTone _supportStatusTone(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('open')) {
      return StatusBadgeTone.warning;
    }
    if (normalized.contains('review')) {
      return StatusBadgeTone.info;
    }
    if (normalized.contains('resolve')) {
      return StatusBadgeTone.success;
    }
    return StatusBadgeTone.neutral;
  }

  static String _formatPrice(int cents) {
    final value = cents / 100;
    return '\$${value.toStringAsFixed(2)}';
  }

  static String _supportMessageForIssue(String issueType) {
    return switch (issueType) {
      'MISSING_ITEM' => 'A cart item was missing from the order.',
      'LATE_DELIVERY' => 'The delivery arrived later than expected.',
      'DAMAGED_ITEM' => 'An item arrived damaged and needs review.',
      _ => 'A customer support issue needs attention.',
    };
  }

  static String _orderEtaText(CustomerOrderSummary order) {
    final status = order.status ?? 'UNKNOWN';
    final normalized = status.toUpperCase();
    final placedAt = order.placedAt;
    if (normalized == 'CANCELED') {
      return 'Canceled';
    }
    if (placedAt == null) {
      return _humanizeStatus(status);
    }

    final elapsed =
        DateTime.now().toUtc().difference(placedAt.toUtc()).inMinutes;
    if (normalized == 'DELIVERED') {
      return 'Delivered $elapsed min ago';
    }

    return 'Placed $elapsed min ago';
  }

  static String _humanizeStatus(String status) {
    return status.toLowerCase().split('_').map((segment) {
      if (segment.isEmpty) {
        return segment;
      }

      return '${segment[0].toUpperCase()}${segment.substring(1)}';
    }).join(' ');
  }

  static List<Color> _gradientForSeed(String seed) {
    const palette = <List<Color>>[
      <Color>[Color(0xFF98D8D6), Color(0xFFC8E3AF)],
      <Color>[Color(0xFFB1D7EF), Color(0xFFC9E8CF)],
      <Color>[Color(0xFFAAD8B4), Color(0xFFE3E5BE)],
      <Color>[Color(0xFFA2D1E2), Color(0xFFC9E1BC)],
      <Color>[Color(0xFFBDD9E9), Color(0xFFDCE9C2)],
      <Color>[Color(0xFF9FCFDF), Color(0xFFC7E3BE)],
    ];

    var hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = (hash + codeUnit) % palette.length;
    }

    return palette[hash];
  }

  static List<StoreOption> _storeOptionsFromBootstrap(
      CustomerBootstrap? bootstrap) {
    if (bootstrap == null) {
      return const <StoreOption>[];
    }

    final stores = <StoreOption>[];
    for (final retailer in bootstrap.retailers) {
      // Flatten retailers into location-specific choices because the customer
      // UI always browses a concrete store location.
      for (final location in retailer.locations) {
        if (!location.isActive) {
          continue;
        }

        stores.add(
          StoreOption(
            id: location.retailerLocationId,
            retailerId: retailer.retailerId,
            name: location.name,
            subtitle: _storeSubtitle(location),
            isConnected: retailer.isConnected,
          ),
        );
      }
    }

    return stores;
  }

  static String _storeSubtitle(RetailerLocation location) {
    final parts = <String>[
      if (location.city != null && location.city!.isNotEmpty) location.city!,
      if (location.state != null && location.state!.isNotEmpty) location.state!,
    ];
    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return location.addressLine;
  }

  static String? _resolveSelectedStoreId(
    List<StoreOption> stores,
    String? preferredStoreId,
  ) {
    if (stores.isEmpty) {
      return null;
    }

    if (preferredStoreId != null) {
      for (final store in stores) {
        if (store.id == preferredStoreId) {
          return preferredStoreId;
        }
      }
    }

    // Prefer a previously selected store, then a connected store, and finally
    // the first available location so the shell always has a deterministic
    // selection strategy.
    for (final store in stores) {
      if (store.isConnected) {
        return store.id;
      }
    }

    return stores.first.id;
  }

  StoreOption? get _selectedStoreOption {
    final selectedStoreId = _selectedStoreId;
    if (selectedStoreId == null) {
      return null;
    }

    for (final store in _stores) {
      if (store.id == selectedStoreId) {
        return store;
      }
    }

    return null;
  }

  int _quantityInCartForItem(String productId) {
    for (final line in _cartLines) {
      if (line.productId == productId) {
        return line.quantity;
      }
    }

    return 0;
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_loadError ?? 'Unable to load data.'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _refreshBootstrap,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading && _bootstrap == null) {
      return _buildLoadingState();
    }

    if (_loadError != null && _bootstrap == null) {
      return _buildErrorState();
    }

    return switch (_selectedNavIndex) {
      // The shell keeps all cross-tab state local and hands each tab only the
      // callbacks and derived data it needs.
      0 => CustomerTabHome(
          stores: _stores,
          selectedStoreId: _selectedStoreId,
          previewItems: _homePreviewItems,
          cartLines: _cartLines,
          subtotal: _subtotalCents,
          serviceFee: _serviceFeeCents,
          deliveryFee: _deliveryFeeCents,
          estimatedTax: _estimatedTaxCents,
          total: _totalCents,
          onStoreSelected: _onStoreSelected,
          onAddToCart: _addToCart,
          quantityInCartForItem: _quantityInCartForItem,
          onIncreaseQty: _increaseQty,
          onDecreaseQty: _decreaseQty,
          onRemoveLine: _removeFromCart,
          onClearCart: _clearCart,
          onCheckout: _checkout,
          isBusy: _isMutating,
          formatPrice: _formatPrice,
        ),
      1 => CustomerTabSearch(
          stores: _stores,
          selectedStoreId: _selectedStoreId,
          categories: _catalogCategories,
          selectedCategory: _selectedCatalogCategory,
          visibleItems: _visibleCatalogItems,
          cartItemCount:
              _cartLines.fold<int>(0, (sum, line) => sum + line.quantity),
          cartTotal: _totalCents,
          onStoreSelected: _onStoreSelected,
          onSearchChanged: (value) {
            setState(() {
              _catalogSearchQuery = value;
            });
          },
          onCategorySelected: (category) {
            setState(() {
              _selectedCatalogCategory = category;
            });
          },
          onAddToCart: _addToCart,
          quantityInCartForItem: _quantityInCartForItem,
          onGoToHome: () {
            setState(() {
              _selectedNavIndex = 0;
            });
          },
          formatPrice: _formatPrice,
        ),
      2 => CustomerTabOrders(
          orders: _orders,
          formatPrice: _formatPrice,
          orderStatusTone: _orderStatusTone,
          onViewOrder: _showOrderDetails,
        ),
      3 => CustomerTabSupport(
          supportTickets: _supportTickets,
          supportStatusTone: _supportStatusTone,
          onCreateTicket: _createSupportTicket,
          isSubmitting: _isSubmittingSupport,
        ),
      _ => CustomerTabAccount(
          overview: _accountOverview,
          onToggleStoreConnection: _toggleRetailerConnection,
          onAddAddress: _showAddAddressDialog,
          onEditAddress: _showEditAddressDialog,
          onDeleteAddress: _showDeleteAddressDialog,
          isBusy: _isMutating,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _accountOverview.customerName;
    final subtitle = _selectedStoreOption?.name ?? widget.session.user.email;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              CustomerTopBar(
                title: title,
                subtitle: subtitle,
                onProfileAction: _onProfileAction,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        items: customerBottomNavItems,
        selectedIndex: _selectedNavIndex,
        onSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<CustomerNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        // Stable keys make the bottom navigation easy to target in tests.
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, key: Key('customer-nav-${item.label}')),
            label: item.label,
          ),
      ],
    );
  }
}

class _AddressInput {
  const _AddressInput({
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.instructions,
    required this.isDefault,
  });

  final String label;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String instructions;
  final bool isDefault;
}

/// Shared dialog used to add or edit a saved delivery address.
class _AddressDialog extends StatefulWidget {
  const _AddressDialog({this.initialAddress});

  final AddressPreview? initialAddress;

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _instructionsController;
  late bool _isDefault;
  String? _errorText;

  bool get _isEditing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final initialAddress = widget.initialAddress;
    _labelController = TextEditingController(
      text: initialAddress?.label ?? 'Primary',
    );
    _line1Controller = TextEditingController(text: initialAddress?.line1 ?? '');
    _line2Controller = TextEditingController(text: initialAddress?.line2 ?? '');
    _cityController = TextEditingController(text: initialAddress?.city ?? '');
    _stateController = TextEditingController(text: initialAddress?.state ?? '');
    _postalCodeController = TextEditingController(
      text: initialAddress?.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: initialAddress?.country ?? 'US',
    );
    _instructionsController = TextEditingController(
      text: initialAddress?.instructions ?? '',
    );
    _isDefault = initialAddress?.isDefault ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_line1Controller.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _postalCodeController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'Line 1, city, state, and postal code are required.';
      });
      return;
    }

    // Normalize defaults in one place before sending the record to the generic
    // resource API.
    Navigator.of(context).pop(
      _AddressInput(
        label: _labelController.text.trim().isEmpty
            ? 'Address'
            : _labelController.text.trim(),
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? 'US'
            : _countryController.text.trim(),
        instructions: _instructionsController.text.trim(),
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit address' : 'Add address'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('address-label-field'),
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-line1-field'),
              controller: _line1Controller,
              decoration: const InputDecoration(labelText: 'Line 1'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-line2-field'),
              controller: _line2Controller,
              decoration: const InputDecoration(labelText: 'Line 2'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-city-field'),
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-state-field'),
              controller: _stateController,
              decoration: const InputDecoration(labelText: 'State'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-postal-code-field'),
              controller: _postalCodeController,
              decoration: const InputDecoration(labelText: 'Postal code'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-country-field'),
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('address-instructions-field'),
              controller: _instructionsController,
              decoration: const InputDecoration(labelText: 'Instructions'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('address-default-toggle'),
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
              title: const Text('Make default'),
            ),
            if (_errorText != null)
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('address-dialog-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('address-dialog-submit'),
          onPressed: _submit,
          child: Text(_isEditing ? 'Save changes' : 'Save'),
        ),
      ],
    );
  }
}

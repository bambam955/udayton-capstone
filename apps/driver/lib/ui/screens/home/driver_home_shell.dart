import 'package:bizrush_shared/api.dart';
import 'package:flutter/material.dart';

import '../../widgets/driver_top_bar.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/surface_card.dart';
import 'driver_delivery_map_screen.dart';
import 'driver_geocoding_service.dart';
import 'driver_home_models.dart';
import 'driver_job_details_sheet.dart';
import 'tabs/driver_tab_deliveries.dart';
import 'tabs/driver_tab_earnings.dart';
import 'tabs/driver_tab_home.dart';
import 'tabs/driver_tab_nearby.dart';
import 'tabs/driver_tab_support.dart';

/// Owns state coordination for driver home tabs and API-backed actions.
class DriverHomeShell extends StatefulWidget {
  const DriverHomeShell({
    super.key,
    required this.session,
    required this.authApi,
    required this.driverApi,
    required this.resourceApi,
    required this.onSignedOut,
    this.geocodingService = const DriverGeocodingService(),
    this.initialRoutePath = driverDefaultRoutePath,
    this.onRouteChanged,
  });

  final ApiSession session;
  final AuthApi authApi;
  final DriverMobileApi driverApi;
  final ResourceApi resourceApi;
  final VoidCallback onSignedOut;
  final DriverGeocodingService geocodingService;
  final String initialRoutePath;
  final ValueChanged<String>? onRouteChanged;

  @override
  State<DriverHomeShell> createState() => _DriverHomeShellState();
}

class _DriverHomeShellState extends State<DriverHomeShell> {
  DriverBootstrap? _bootstrap;
  List<ResourceDriverEarning> _earnings = const <ResourceDriverEarning>[];
  List<ResourceDriverPayout> _payouts = const <ResourceDriverPayout>[];
  late int _selectedNavIndex;
  int _deliveriesFilterIndex = 0;
  String _searchQueryNearby = '';
  bool _isLoading = true;
  bool _isMutating = false;
  bool _isSubmittingSupport = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedNavIndex = driverNavIndexForRoutePath(widget.initialRoutePath);
    _refreshData();
  }

  @override
  void didUpdateWidget(covariant DriverHomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialRoutePath == oldWidget.initialRoutePath) {
      return;
    }

    final nextIndex = driverNavIndexForRoutePath(widget.initialRoutePath);
    if (nextIndex == _selectedNavIndex) {
      return;
    }

    // Browser back/forward updates arrive as route changes from the root
    // router, so the selected tab needs to follow the incoming route.
    setState(() {
      _selectedNavIndex = nextIndex;
    });
  }

  // The Nearby tab filters only the available-offer lane, leaving active and
  // completed work untouched.
  List<DriverJob> get _availableJobs {
    final query = _searchQueryNearby.trim().toLowerCase();
    return _mapJobs(_bootstrap?.availableJobs).where((job) {
      if (query.isEmpty) {
        return true;
      }

      return job.title.toLowerCase().contains(query) ||
          job.pickup.toLowerCase().contains(query) ||
          job.dropoff.toLowerCase().contains(query) ||
          job.zone.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  List<DriverJob> get _activeJobs => _mapJobs(_bootstrap?.activeJobs);

  List<DriverJob> get _completedJobs => _mapJobs(_bootstrap?.completedJobs);

  String get _driverStatusLabel {
    final rawStatus = _bootstrap?.driver.status?.trim();
    if (rawStatus == null || rawStatus.isEmpty) {
      return widget.session.user.email;
    }

    return rawStatus;
  }

  bool get _isDriverOnline => _driverStatusLabel.toUpperCase() == 'ONLINE';

  List<DriverSupportCase> get _supportCases {
    final bootstrap = _bootstrap;
    if (bootstrap == null) {
      return const <DriverSupportCase>[];
    }

    return <DriverSupportCase>[
      for (final ticket in bootstrap.supportTickets)
        DriverSupportCase(
          id: ticket.ticketId,
          title: ticket.title,
          status: ticket.status ?? 'OPEN',
          summary: ticket.summary,
          linkedDeliveryId: ticket.deliveryId,
        ),
    ];
  }

  DriverPayoutSummary get _payoutSummary {
    final summary = _bootstrap?.earningsSummary;
    if (summary == null) {
      return const DriverPayoutSummary(
        todayGross: 0,
        tips: 0,
        bonus: 0,
        nextPayoutText: 'Unavailable',
      );
    }

    return DriverPayoutSummary(
      todayGross: summary.todayGrossCents / 100,
      tips: summary.tipsCents / 100,
      bonus: summary.bonusCents / 100,
      nextPayoutText: summary.nextPayoutLabel,
    );
  }

  List<DriverPayoutRecord> get _payoutRecords {
    return <DriverPayoutRecord>[
      for (final payout in _payouts)
        DriverPayoutRecord(
          id: payout.payoutId,
          amount: payout.amountCents / 100,
          status: payout.status ?? 'UNKNOWN',
          provider: payout.provider ?? 'Provider',
        ),
    ];
  }

  List<DriverJob> _mapJobs(List<DriverJobSummary>? jobs) {
    if (jobs == null) {
      return const <DriverJob>[];
    }

    return <DriverJob>[
      for (final job in jobs) _mapJob(job),
    ];
  }

  DriverJob _mapJob(DriverJobSummary job) {
    // The driver UI uses richer presentation fields than the API returns, so
    // derive formatted text, synthetic colors, and an approximate starting
    // point for map simulation here in one place.
    return DriverJob(
      id: job.deliveryId,
      title: job.title,
      driverStartLat: job.pickupLat == null || job.pickupLng == null
          ? null
          : job.pickupLat! + 0.02,
      driverStartLng: job.pickupLat == null || job.pickupLng == null
          ? null
          : job.pickupLng! - 0.02,
      pickup: job.pickupName,
      pickupAddressLine: job.pickupAddressLine,
      pickupStoreId: job.pickupLocationId ?? job.deliveryId,
      pickupLat: job.pickupLat,
      pickupLng: job.pickupLng,
      dropoff: job.dropoffName,
      dropoffAddressLine: job.dropoffAddressLine,
      dropoffLat: null,
      dropoffLng: null,
      zone: job.zone,
      payEstimateText: '${_formatMoney(job.payoutEstimateCents / 100)} est.',
      distanceText: '${job.distanceMiles.toStringAsFixed(1)} mi total',
      etaText: '${job.etaMinutes} min route',
      stage: _stageFromApi(job.stage),
      detailLines: job.detailLines,
      gradient: _gradientForSeed(job.deliveryId),
      basePay: job.basePayCents / 100,
      tipAmount: job.tipCents / 100,
      orderId: job.orderId,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      // Bootstrap provides the dispatch-centric read model, while the generic
      // resource API fills in ledger-style earnings and payout tables.
      final bootstrap = await widget.driverApi.bootstrap();
      final earnings = await widget.resourceApi.list<ResourceDriverEarning>(
        '/v1/driver-earnings',
        ResourceDriverEarning.fromJson,
        queryParameters: const <String, String>{'limit': '20'},
      );
      final payouts = await widget.resourceApi.list<ResourceDriverPayout>(
        '/v1/driver-payouts',
        ResourceDriverPayout.fromJson,
        queryParameters: const <String, String>{'limit': '10'},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _bootstrap = bootstrap;
        _earnings = earnings;
        _payouts = payouts;
        _isLoading = false;
      });
    } on ApiError catch (error) {
      await _handleApiError(
        error,
        fallbackMessage: 'Unable to load driver data.',
        setLoadError: true,
      );
    }
  }

  Future<void> _acceptJob(String jobId) async {
    setState(() {
      _isMutating = true;
    });

    try {
      await widget.driverApi.acceptDelivery(jobId);
      await _refreshData();
      final updatedJob = _findJob(jobId);
      if (updatedJob != null) {
        // Immediately launch route guidance once the backend confirms the
        // assignment so the accept action feels like a dispatch handoff.
        await _openMap(updatedJob, DriverRoutePhase.toPickup);
      }
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to accept delivery.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _confirmPickup(String jobId) async {
    setState(() {
      _isMutating = true;
    });

    try {
      await widget.driverApi.pickupDelivery(jobId);
      await _refreshData();
      final updatedJob = _findJob(jobId);
      if (updatedJob != null) {
        await _openMap(updatedJob, DriverRoutePhase.toDropoff);
      }
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to confirm pickup.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _completeDelivery(String jobId) async {
    setState(() {
      _isMutating = true;
    });

    try {
      await widget.driverApi.completeDelivery(jobId);
      await _refreshData();
      _showMessage('Delivery completed.');
    } on ApiError catch (error) {
      await _handleApiError(error,
          fallbackMessage: 'Unable to complete delivery.');
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _createTicket(String issueType) async {
    setState(() {
      _isSubmittingSupport = true;
    });

    try {
      // Attach new support requests to the most relevant recent job when
      // possible so the admin side has delivery context immediately.
      final activeJob = _activeJobs.isNotEmpty
          ? _activeJobs.first
          : (_completedJobs.isEmpty ? null : _completedJobs.first);
      await widget.resourceApi.create<ResourceDriverSupportTicket>(
        '/v1/driver-support-tickets',
        <String, Object?>{
          if (activeJob != null) 'delivery_id': activeJob.id,
          if (activeJob != null) 'order_id': activeJob.orderId,
          'issue_type': issueType,
          'message': _supportMessageForIssue(issueType),
        },
        ResourceDriverSupportTicket.fromJson,
      );
      await _refreshData();
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

  Future<void> _setAvailability(bool isOnline) async {
    setState(() {
      _isMutating = true;
    });

    try {
      await widget.resourceApi.update<ResourceDriver>(
        '/v1/drivers/${widget.session.user.id}',
        <String, Object?>{
          'status': isOnline ? 'ONLINE' : 'OFFLINE',
        },
        ResourceDriver.fromJson,
      );
      await _refreshData();
      _showMessage(
        isOnline
            ? 'You are online and can receive delivery offers.'
            : 'You are offline and hidden from new delivery offers.',
      );
    } on ApiError catch (error) {
      await _handleApiError(
        error,
        fallbackMessage: 'Unable to update driver status.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMutating = false;
        });
      }
    }
  }

  DriverJob? _findJob(String jobId) {
    for (final job in <DriverJob>[
      ..._availableJobs,
      ..._activeJobs,
      ..._completedJobs
    ]) {
      if (job.id == jobId) {
        return job;
      }
    }

    return null;
  }

  Future<void> _openDetails(DriverJob job) {
    return showDriverJobDetailsSheet(
      context: context,
      job: job,
      stageLabel: _stageLabel(job.stage),
      stageTone: _stageTone(job.stage),
    );
  }

  Future<void> _openMap(DriverJob job, DriverRoutePhase phase) async {
    final resolvedJob = await _resolveJobForMap(job, phase);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DriverDeliveryMapScreen(job: resolvedJob, phase: phase),
      ),
    );
  }

  Future<DriverJob> _resolveJobForMap(
      DriverJob job, DriverRoutePhase phase) async {
    var resolvedJob = job;

    if (resolvedJob.pickupLat == null || resolvedJob.pickupLng == null) {
      try {
        // Bootstrap payloads may only know the pickup address. Resolve lazily
        // right before the map opens so the shell does not block on geocoding.
        final pickupResult = await widget.geocodingService
            .geocodeAddress(resolvedJob.pickupAddressLine);
        if (pickupResult != null) {
          resolvedJob = resolvedJob.withPickupCoordinates(
            pickupLat: pickupResult.lat,
            pickupLng: pickupResult.lng,
          );
        }
      } catch (_) {
        // Leave pickup unresolved so the map screen can fail closed and still
        // offer address-based external navigation.
      }
    }

    if (phase != DriverRoutePhase.toDropoff ||
        (resolvedJob.dropoffLat != null && resolvedJob.dropoffLng != null)) {
      return resolvedJob;
    }

    try {
      final result = await widget.geocodingService
          .geocodeAddress(resolvedJob.dropoffAddressLine);
      if (result == null) {
        return resolvedJob;
      }

      return resolvedJob.withDropoffCoordinates(
        dropoffLat: result.lat,
        dropoffLng: result.lng,
      );
    } catch (_) {
      // Keep the existing route-screen fallback when geocoding cannot resolve a
      // precise point in time.
      return resolvedJob;
    }
  }

  void _openMapForActiveJob(String jobId) {
    final job = _findJob(jobId);
    if (job == null) {
      return;
    }

    final phase = switch (job.stage) {
      DeliveryStage.assigned => DriverRoutePhase.toPickup,
      DeliveryStage.outForDelivery => DriverRoutePhase.toDropoff,
      _ => null,
    };
    if (phase == null) {
      return;
    }

    _openMap(job, phase);
  }

  Future<void> _onProfileAction(String action) async {
    if (action != 'sign_out') {
      return;
    }

    await widget.authApi.logout(widget.session.user.role).catchError((_) {});
    if (!mounted) {
      return;
    }
    widget.onSignedOut();
  }

  Future<void> _handleApiError(
    ApiError error, {
    required String fallbackMessage,
    bool setLoadError = false,
  }) async {
    if (error.kind == ApiErrorKind.unauthorized) {
      // Unauthorized means the server-side session has effectively expired, so
      // force a full sign-out and let the auth screen restart the flow.
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static DeliveryStage _stageFromApi(String stage) {
    return switch (stage) {
      'assigned' => DeliveryStage.assigned,
      'out_for_delivery' => DeliveryStage.outForDelivery,
      'delivered' => DeliveryStage.delivered,
      _ => DeliveryStage.available,
    };
  }

  static String _stageLabel(DeliveryStage stage) {
    return switch (stage) {
      DeliveryStage.available => 'AVAILABLE',
      DeliveryStage.assigned => 'ASSIGNED',
      DeliveryStage.outForDelivery => 'OUT_FOR_DELIVERY',
      DeliveryStage.delivered => 'COMPLETED',
    };
  }

  static StatusBadgeTone _stageTone(DeliveryStage stage) {
    return switch (stage) {
      DeliveryStage.assigned => StatusBadgeTone.assigned,
      DeliveryStage.outForDelivery => StatusBadgeTone.outForDelivery,
      DeliveryStage.delivered => StatusBadgeTone.completed,
      _ => StatusBadgeTone.neutral,
    };
  }

  static String _supportMessageForIssue(String issueType) {
    return switch (issueType) {
      'PICKUP_ISSUE' => 'The pickup handoff has an issue that needs support.',
      'DELIVERY_ISSUE' => 'The dropoff step needs support assistance.',
      'PAYMENT_QUESTION' => 'The driver has a payout or earnings question.',
      _ => 'Driver requested support.',
    };
  }

  static String _formatMoney(double value) => r'$' + value.toStringAsFixed(2);

  static List<Color> _gradientForSeed(String seed) {
    const palette = <List<Color>>[
      <Color>[Color(0xFF7FD5CC), Color(0xFFB6E0AE)],
      <Color>[Color(0xFF8FC9F2), Color(0xFFADE6D2)],
      <Color>[Color(0xFF9FD3E2), Color(0xFFC8E8C5)],
      <Color>[Color(0xFFBFD7EE), Color(0xFFDAEBC0)],
      <Color>[Color(0xFF95D0D8), Color(0xFFD0E8C5)],
      <Color>[Color(0xFFA8D6D9), Color(0xFFDBE8BE)],
    ];

    var hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = (hash + codeUnit) % palette.length;
    }

    return palette[hash];
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
            onPressed: _refreshData,
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
      // The shell owns all cross-tab state and passes each tab the narrow slice
      // of callbacks/data it needs.
      0 => DriverTabHome(
          availableJobs: _availableJobs,
          activeJobs: _activeJobs,
          completedJobs: _completedJobs,
          payout: _payoutSummary,
          onGoToDeliveries: () => _onNavSelected(2),
          onGoToNearby: () => _onNavSelected(1),
          formatMoney: _formatMoney,
        ),
      1 => DriverTabNearby(
          availableJobs: _availableJobs,
          onSearchChanged: (value) {
            setState(() {
              _searchQueryNearby = value;
            });
          },
          onRefreshOffers: _refreshData,
          onAccept: _acceptJob,
          onViewDetails: _openDetails,
          isBusy: _isMutating,
          isRefreshingOffers: _isLoading,
        ),
      2 => DriverTabDeliveries(
          filterIndex: _deliveriesFilterIndex,
          activeJobs: _activeJobs,
          completedJobs: _completedJobs,
          stageLabel: _stageLabel,
          stageTone: _stageTone,
          onFilterChanged: (index) {
            setState(() {
              _deliveriesFilterIndex = index;
            });
          },
          onConfirmPickup: _confirmPickup,
          onCompleteDelivery: _completeDelivery,
          onOpenMap: _openMapForActiveJob,
          onViewDetails: _openDetails,
          isBusy: _isMutating,
        ),
      3 => DriverTabEarnings(
          payout: _payoutSummary,
          completedJobs: _completedJobs,
          payouts: _payoutRecords,
          earnings: _earnings,
          formatMoney: _formatMoney,
        ),
      _ => DriverTabSupport(
          supportCases: _supportCases,
          onCreateTicket: _createTicket,
          isSubmitting: _isSubmittingSupport,
        ),
    };
  }

  void _onNavSelected(int index) {
    final safeIndex = index.clamp(0, driverBottomNavItems.length - 1).toInt();
    if (_selectedNavIndex != safeIndex) {
      setState(() {
        _selectedNavIndex = safeIndex;
      });
    }

    widget.onRouteChanged?.call(driverBottomNavItems[safeIndex].routePath);
  }

  @override
  Widget build(BuildContext context) {
    final driverName = _bootstrap?.driver.fullName?.trim();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              DriverTopBar(
                title: driverName == null || driverName.isEmpty
                    ? 'Driver'
                    : driverName,
                subtitle: _driverStatusLabel,
                isOnline: _isDriverOnline,
                isAvailabilityBusy: _isMutating,
                onAvailabilityChanged: _setAvailability,
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
        items: driverBottomNavItems,
        selectedIndex: _selectedNavIndex,
        onSelected: _onNavSelected,
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

  final List<DriverNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        // Stable keys keep widget tests tied to labels instead of index order.
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, key: Key('driver-nav-${item.label}')),
            label: item.label,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/driver_top_bar.dart';
import '../../widgets/status_badge.dart';
import 'driver_home_fake_data.dart';
import 'driver_home_models.dart';
import 'driver_job_details_sheet.dart';
import 'tabs/driver_tab_deliveries.dart';
import 'tabs/driver_tab_earnings.dart';
import 'tabs/driver_tab_home.dart';
import 'tabs/driver_tab_nearby.dart';
import 'tabs/driver_tab_support.dart';

/// Owns state coordination for driver home tabs and actions.
class DriverHomeShell extends StatefulWidget {
  const DriverHomeShell({super.key});

  @override
  State<DriverHomeShell> createState() => _DriverHomeShellState();
}

class _DriverHomeShellState extends State<DriverHomeShell> {
  int _selectedNavIndex = 0;
  int _deliveriesFilterIndex = 0;
  int _supportCaseSeed = 300;
  String _searchQueryNearby = '';

  late final List<DriverJob> _jobs = initialDriverJobs
      .map((job) =>
          job.copyWith(detailLines: List<String>.from(job.detailLines)))
      .toList();

  late final List<DriverSupportCase> _supportCases =
      List<DriverSupportCase>.from(initialDriverSupportCases);

  List<DriverJob> get _availableJobs {
    final query = _searchQueryNearby.trim().toLowerCase();
    return _jobs.where((job) {
      if (job.stage != DeliveryStage.available) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return job.title.toLowerCase().contains(query) ||
          job.pickup.toLowerCase().contains(query) ||
          job.dropoff.toLowerCase().contains(query) ||
          job.zone.toLowerCase().contains(query);
    }).toList();
  }

  List<DriverJob> get _activeJobs {
    return _jobs
        .where((job) =>
            job.stage == DeliveryStage.assigned ||
            job.stage == DeliveryStage.outForDelivery)
        .toList();
  }

  List<DriverJob> get _completedJobs {
    return _jobs.where((job) => job.stage == DeliveryStage.delivered).toList();
  }

  DriverPayoutSummary get _payoutSummary {
    final tips = _completedJobs.fold<double>(
      0,
      (sum, job) => sum + job.tipAmount,
    );
    final base = _completedJobs.fold<double>(
      0,
      (sum, job) => sum + job.basePay,
    );
    final bonus = _completedJobs.length >= 3 ? 8.0 : 0.0;

    return DriverPayoutSummary(
      todayGross: base + tips + bonus,
      tips: tips,
      bonus: bonus,
      nextPayoutText: 'Tomorrow 9:00 AM',
    );
  }

  void _onNavSelected(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _showDemoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onProfileAction(String action) {
    final message = switch (action) {
      'view_profile' => 'View profile clicked (demo only)',
      'switch_role' => 'Switch role clicked (demo only)',
      'sign_out' => 'Sign out clicked (demo only)',
      _ => 'Action clicked (demo only)',
    };

    _showDemoMessage(message);
  }

  void _acceptJob(String jobId) {
    final job = _findJob(jobId);
    if (job == null || job.stage != DeliveryStage.available) {
      return;
    }

    setState(() {
      _updateJobStage(jobId, DeliveryStage.assigned);
    });

    _showDemoMessage('${job.title} accepted (demo only)');
  }

  void _confirmPickup(String jobId) {
    final job = _findJob(jobId);
    if (job == null || job.stage != DeliveryStage.assigned) {
      return;
    }

    setState(() {
      _updateJobStage(jobId, DeliveryStage.outForDelivery);
    });

    _showDemoMessage('Pickup confirmed for ${job.title} (demo only)');
  }

  void _completeDelivery(String jobId) {
    final job = _findJob(jobId);
    if (job == null || job.stage != DeliveryStage.outForDelivery) {
      return;
    }

    setState(() {
      _updateJobStage(jobId, DeliveryStage.delivered);
    });

    _showDemoMessage('Delivery completed for ${job.title} (demo only)');
  }

  void _createDemoTicket() {
    final linkedJob = _activeJobs.isNotEmpty
        ? _activeJobs.first.id
        : (_completedJobs.isNotEmpty ? _completedJobs.first.id : null);

    setState(() {
      _supportCaseSeed += 1;
      _supportCases.insert(
        0,
        DriverSupportCase(
          id: 'DS-$_supportCaseSeed',
          title: 'New demo support ticket',
          status: 'Open',
          summary: 'Driver created a demo support ticket from the support tab.',
          linkedDeliveryId: linkedJob,
        ),
      );
    });

    _showDemoMessage('Support ticket created (demo only)');
  }

  DriverJob? _findJob(String jobId) {
    for (final job in _jobs) {
      if (job.id == jobId) {
        return job;
      }
    }
    return null;
  }

  void _updateJobStage(String jobId, DeliveryStage stage) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index < 0) {
      return;
    }

    _jobs[index] = _jobs[index].copyWith(stage: stage);
  }

  Future<void> _openDetails(DriverJob job) {
    return showDriverJobDetailsSheet(
      context: context,
      job: job,
      stageLabel: _stageLabel(job.stage),
      stageTone: _stageTone(job.stage),
    );
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

  static String _formatMoney(double value) => r'$' + value.toStringAsFixed(2);

  Widget _buildTabContent() {
    return switch (_selectedNavIndex) {
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
          onAccept: _acceptJob,
          onViewDetails: _openDetails,
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
          onViewDetails: _openDetails,
        ),
      3 => DriverTabEarnings(
          payout: _payoutSummary,
          completedJobs: _completedJobs,
          formatMoney: _formatMoney,
        ),
      _ => DriverTabSupport(
          supportCases: _supportCases,
          onQuickAction: _showDemoMessage,
          onCreateTicket: _createDemoTicket,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              DriverTopBar(onProfileAction: _onProfileAction),
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
        for (final item in items)
          NavigationDestination(
            icon: Icon(item.icon, key: Key('driver-nav-${item.label}')),
            label: item.label,
          ),
      ],
    );
  }
}

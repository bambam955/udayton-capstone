import 'package:flutter/material.dart';

/// Owns data types used by the driver home shell and tab sections.
enum DeliveryStage { available, assigned, outForDelivery, delivered }

/// Identifies whether the map screen should route the driver to pickup or to
/// the customer dropoff.
enum DriverRoutePhase { toPickup, toDropoff }

/// Presentation model consumed by the driver UI.
class DriverJob {
  const DriverJob({
    required this.id,
    required this.title,
    required this.driverStartLat,
    required this.driverStartLng,
    required this.pickup,
    required this.pickupAddressLine,
    required this.pickupStoreId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoff,
    required this.dropoffAddressLine,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.zone,
    required this.payEstimateText,
    required this.distanceText,
    required this.etaText,
    required this.stage,
    required this.detailLines,
    required this.gradient,
    required this.basePay,
    required this.tipAmount,
    required this.orderId,
  });

  final String id;
  final String title;
  final double? driverStartLat;
  final double? driverStartLng;
  final String pickup;
  final String pickupAddressLine;
  final String pickupStoreId;
  final double? pickupLat;
  final double? pickupLng;
  final String dropoff;
  final String dropoffAddressLine;
  final double? dropoffLat;
  final double? dropoffLng;
  final String zone;
  final String payEstimateText;
  final String distanceText;
  final String etaText;
  final DeliveryStage stage;
  final List<String> detailLines;
  final List<Color> gradient;
  final double basePay;
  final double tipAmount;
  final String orderId;

  // Dropoff coordinates are resolved lazily because most API payloads still
  // provide only the customer-facing address line at assignment time.
  DriverJob withPickupCoordinates({
    required double pickupLat,
    required double pickupLng,
  }) {
    return DriverJob(
      id: id,
      title: title,
      driverStartLat: driverStartLat ?? pickupLat + 0.02,
      driverStartLng: driverStartLng ?? pickupLng - 0.02,
      pickup: pickup,
      pickupAddressLine: pickupAddressLine,
      pickupStoreId: pickupStoreId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoff: dropoff,
      dropoffAddressLine: dropoffAddressLine,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      zone: zone,
      payEstimateText: payEstimateText,
      distanceText: distanceText,
      etaText: etaText,
      stage: stage,
      detailLines: detailLines,
      gradient: gradient,
      basePay: basePay,
      tipAmount: tipAmount,
      orderId: orderId,
    );
  }

  // Pickup coordinates may arrive later than the rest of the job payload, so
  // expose a copy helper instead of mutating the model in place.
  DriverJob withDropoffCoordinates({
    required double dropoffLat,
    required double dropoffLng,
  }) {
    return DriverJob(
      id: id,
      title: title,
      driverStartLat: driverStartLat,
      driverStartLng: driverStartLng,
      pickup: pickup,
      pickupAddressLine: pickupAddressLine,
      pickupStoreId: pickupStoreId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoff: dropoff,
      dropoffAddressLine: dropoffAddressLine,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      zone: zone,
      payEstimateText: payEstimateText,
      distanceText: distanceText,
      etaText: etaText,
      stage: stage,
      detailLines: detailLines,
      gradient: gradient,
      basePay: basePay,
      tipAmount: tipAmount,
      orderId: orderId,
    );
  }
}

/// Presentation model for driver support summaries.
class DriverSupportCase {
  const DriverSupportCase({
    required this.id,
    required this.title,
    required this.status,
    required this.summary,
    this.linkedDeliveryId,
  });

  final String id;
  final String title;
  final String status;
  final String summary;
  final String? linkedDeliveryId;
}

/// Small aggregate for the driver earnings summary card.
class DriverPayoutSummary {
  const DriverPayoutSummary({
    required this.todayGross,
    required this.tips,
    required this.bonus,
    required this.nextPayoutText,
  });

  final double todayGross;
  final double tips;
  final double bonus;
  final String nextPayoutText;
}

/// Historical payout row rendered in the earnings tab.
class DriverPayoutRecord {
  const DriverPayoutRecord({
    required this.id,
    required this.amount,
    required this.status,
    required this.provider,
  });

  final String id;
  final double amount;
  final String status;
  final String provider;
}

/// Navigation item backing the driver's bottom navigation bar.
class DriverNavItem {
  const DriverNavItem({
    required this.icon,
    required this.label,
    required this.routePath,
  });

  final IconData icon;
  final String label;
  final String routePath;
}

const String driverDefaultRoutePath = '/home';

/// Shared nav configuration so the shell and tests derive labels from one list.
const driverBottomNavItems = <DriverNavItem>[
  DriverNavItem(
    icon: Icons.home_rounded,
    label: 'Home',
    routePath: driverDefaultRoutePath,
  ),
  DriverNavItem(
    icon: Icons.place_rounded,
    label: 'Nearby',
    routePath: '/nearby',
  ),
  DriverNavItem(
    icon: Icons.local_shipping_rounded,
    label: 'Deliveries',
    routePath: '/deliveries',
  ),
  DriverNavItem(
    icon: Icons.payments_rounded,
    label: 'Earnings',
    routePath: '/earnings',
  ),
  DriverNavItem(
    icon: Icons.headset_mic_rounded,
    label: 'Support',
    routePath: '/support',
  ),
];

/// Keeps browser URLs, startup routes, and tab indexes aligned.
String driverNormalizeRoutePath(String? routePath) {
  final path = routePath == null ? '' : Uri.tryParse(routePath)?.path ?? '';
  if (path.isEmpty || path == '/') {
    return driverDefaultRoutePath;
  }

  for (final item in driverBottomNavItems) {
    if (item.routePath == path) {
      return path;
    }
  }

  // Unknown app routes should land on a useful page instead of a blank shell.
  return driverDefaultRoutePath;
}

int driverNavIndexForRoutePath(String? routePath) {
  final normalizedRoutePath = driverNormalizeRoutePath(routePath);
  for (var index = 0; index < driverBottomNavItems.length; index += 1) {
    if (driverBottomNavItems[index].routePath == normalizedRoutePath) {
      return index;
    }
  }

  return 0;
}

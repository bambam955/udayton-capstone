import 'package:flutter/material.dart';

/// Owns data types used by the driver home shell and tab sections.
enum DeliveryStage { available, assigned, outForDelivery, delivered }

enum DriverRoutePhase { toPickup, toDropoff }

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
  final double driverStartLat;
  final double driverStartLng;
  final String pickup;
  final String pickupAddressLine;
  final String pickupStoreId;
  final double pickupLat;
  final double pickupLng;
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
}

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

class DriverNavItem {
  const DriverNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const driverBottomNavItems = <DriverNavItem>[
  DriverNavItem(icon: Icons.home_rounded, label: 'Home'),
  DriverNavItem(icon: Icons.place_rounded, label: 'Nearby'),
  DriverNavItem(icon: Icons.local_shipping_rounded, label: 'Deliveries'),
  DriverNavItem(icon: Icons.payments_rounded, label: 'Earnings'),
  DriverNavItem(icon: Icons.headset_mic_rounded, label: 'Support'),
];

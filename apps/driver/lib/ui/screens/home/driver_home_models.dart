import 'package:flutter/material.dart';

/// Owns data types used by the driver home shell and tab sections.
enum DeliveryStage { available, assigned, outForDelivery, delivered }

class DriverJob {
  const DriverJob({
    required this.id,
    required this.title,
    required this.pickup,
    required this.dropoff,
    required this.zone,
    required this.payEstimateText,
    required this.distanceText,
    required this.etaText,
    required this.stage,
    required this.detailLines,
    required this.gradient,
    required this.basePay,
    required this.tipAmount,
  });

  final String id;
  final String title;
  final String pickup;
  final String dropoff;
  final String zone;
  final String payEstimateText;
  final String distanceText;
  final String etaText;
  final DeliveryStage stage;
  final List<String> detailLines;
  final List<Color> gradient;
  final double basePay;
  final double tipAmount;

  DriverJob copyWith({DeliveryStage? stage, List<String>? detailLines}) {
    return DriverJob(
      id: id,
      title: title,
      pickup: pickup,
      dropoff: dropoff,
      zone: zone,
      payEstimateText: payEstimateText,
      distanceText: distanceText,
      etaText: etaText,
      stage: stage ?? this.stage,
      detailLines: detailLines ?? this.detailLines,
      gradient: gradient,
      basePay: basePay,
      tipAmount: tipAmount,
    );
  }
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

class DriverNavItem {
  const DriverNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

import 'package:flutter/material.dart';

import 'driver_home_models.dart';

/// Owns static demo data used by the driver home shell.
const driverBottomNavItems = [
  DriverNavItem(icon: Icons.home_rounded, label: 'Home'),
  DriverNavItem(icon: Icons.place_rounded, label: 'Nearby'),
  DriverNavItem(icon: Icons.local_shipping_rounded, label: 'Deliveries'),
  DriverNavItem(icon: Icons.payments_rounded, label: 'Earnings'),
  DriverNavItem(icon: Icons.headset_mic_rounded, label: 'Support'),
];

const initialDriverJobs = [
  DriverJob(
    id: 'drv_job_101',
    title: 'Downtown Grocery Route',
    pickup: 'Target Midtown',
    dropoff: 'Northside Deli',
    zone: 'Downtown',
    payEstimateText: r'$24-$31 est.',
    distanceText: '4.2 mi total',
    etaText: '38 min route',
    stage: DeliveryStage.available,
    detailLines: [
      'Pickup window: 11:20 AM - 11:40 AM',
      'Items: 14',
      'Proof required: Photo + timestamp',
    ],
    gradient: [Color(0xFF7FD5CC), Color(0xFFB6E0AE)],
    basePay: 18.5,
    tipAmount: 5.0,
  ),
  DriverJob(
    id: 'drv_job_102',
    title: 'Harbor Bulk Run',
    pickup: 'Walmart Eastgate',
    dropoff: 'Harbor Print Shop',
    zone: 'Harbor',
    payEstimateText: r'$28-$36 est.',
    distanceText: '6.8 mi total',
    etaText: '52 min route',
    stage: DeliveryStage.available,
    detailLines: [
      'Pickup window: 11:45 AM - 12:05 PM',
      'Items: 22',
      'Dock entrance required',
    ],
    gradient: [Color(0xFF8FC9F2), Color(0xFFADE6D2)],
    basePay: 22.0,
    tipAmount: 7.0,
  ),
  DriverJob(
    id: 'drv_job_220',
    title: 'Midtown Express',
    pickup: 'Target Harbor',
    dropoff: 'Elm Street Cafe',
    zone: 'Midtown',
    payEstimateText: r'$19-$25 est.',
    distanceText: '3.1 mi total',
    etaText: '29 min route',
    stage: DeliveryStage.assigned,
    detailLines: [
      'Status: Assigned and ready for pickup',
      'Items: 9',
      'Customer note: Call upon arrival',
    ],
    gradient: [Color(0xFFC2DCAA), Color(0xFFE6E6BA)],
    basePay: 15.75,
    tipAmount: 4.0,
  ),
  DriverJob(
    id: 'drv_job_330',
    title: 'South Bay Final Leg',
    pickup: 'Walmart Metro',
    dropoff: 'Riverbend Office Co.',
    zone: 'South Bay',
    payEstimateText: r'$16-$22 est.',
    distanceText: '2.7 mi total',
    etaText: '22 min route',
    stage: DeliveryStage.outForDelivery,
    detailLines: [
      'Status: Out for delivery',
      'Items: 7',
      'Proof mode: Contactless photo',
    ],
    gradient: [Color(0xFF95D0D8), Color(0xFFD0E8C5)],
    basePay: 14.25,
    tipAmount: 3.5,
  ),
  DriverJob(
    id: 'drv_job_410',
    title: 'Morning Produce Drop',
    pickup: 'Target Midtown',
    dropoff: 'Central Kitchen Co-op',
    zone: 'Downtown',
    payEstimateText: r'$21-$27 est.',
    distanceText: '4.9 mi total',
    etaText: '41 min route',
    stage: DeliveryStage.delivered,
    detailLines: [
      'Completed at 9:42 AM',
      'Items: 12',
      'Proof uploaded successfully',
    ],
    gradient: [Color(0xFFA8D6D9), Color(0xFFDBE8BE)],
    basePay: 17.25,
    tipAmount: 6.0,
  ),
];

const initialDriverSupportCases = [
  DriverSupportCase(
    id: 'DS-219',
    title: 'Pickup readiness mismatch',
    status: 'In review',
    summary: 'Store marked ready but order still being staged.',
    linkedDeliveryId: 'drv_job_220',
  ),
  DriverSupportCase(
    id: 'DS-224',
    title: 'Drop-off gate access issue',
    status: 'Open',
    summary: 'Customer access instructions were incomplete.',
    linkedDeliveryId: 'drv_job_330',
  ),
];

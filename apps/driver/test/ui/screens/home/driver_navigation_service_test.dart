import 'package:bizrush_driver/ui/screens/home/driver_navigation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds platform navigation urls for a destination', () {
    const destination = DriverNavigationDestination(
      label: 'Target Midtown',
      lat: 40.7506,
      lng: -73.9899,
    );

    expect(
      DriverNavigationService.buildGoogleNavigationUri(destination).toString(),
      'google.navigation:q=40.7506,-73.9899',
    );
    expect(
      DriverNavigationService.buildAppleMapsUri(destination).toString(),
      'https://maps.apple.com/?daddr=40.7506%2C-73.9899',
    );
    expect(
      DriverNavigationService.buildGoogleMapsWebUri(destination).toString(),
      'https://www.google.com/maps/dir/?api=1&destination=40.7506%2C-73.9899',
    );
  });

  test('tries multiple launch candidates until one succeeds', () async {
    final launchedUris = <Uri>[];
    final service = DriverNavigationService(
      launchUrlCallback: (uri, mode) async {
        launchedUris.add(uri);
        return launchedUris.length == 2;
      },
    );

    const destination = DriverNavigationDestination(
      label: 'Dropoff',
      lat: 40.7304,
      lng: -73.9897,
    );

    final launched = await service.navigateTo(destination);

    expect(launched, isTrue);
    expect(launchedUris, hasLength(2));
  });
}

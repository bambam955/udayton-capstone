import 'package:bizrush_shared/bizrush_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('storeLocationById resolves canonical demo stores', () {
    final targetMidtown = storeLocationById('target_midtown');
    final walmartEastgate = storeLocationById('walmart_eastgate');

    expect(targetMidtown.name, 'Target Beavercreek');
    expect(
      targetMidtown.addressLine,
      '2490 N Fairfield Rd, Beavercreek, OH 45431',
    );
    expect(targetMidtown.lat, 39.7706);
    expect(targetMidtown.lng, -84.0584);

    expect(walmartEastgate.name, 'Walmart Moraine');
    expect(
      walmartEastgate.addressLine,
      '1701 W Dorothy Ln, Moraine, OH 45439',
    );
  });
}

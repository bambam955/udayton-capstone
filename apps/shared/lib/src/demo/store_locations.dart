enum StoreRetailer { target, walmart }

class StoreLocation {
  const StoreLocation({
    required this.id,
    required this.name,
    required this.addressLine,
    required this.lat,
    required this.lng,
    required this.retailer,
  });

  final String id;
  final String name;
  final String addressLine;
  final double lat;
  final double lng;
  final StoreRetailer retailer;
}

const storeLocations = [
  StoreLocation(
    id: 'target_midtown',
    name: 'Target Beavercreek',
    addressLine: '2490 N Fairfield Rd, Beavercreek, OH 45431',
    lat: 39.7706,
    lng: -84.0584,
    retailer: StoreRetailer.target,
  ),
  StoreLocation(
    id: 'walmart_eastgate',
    name: 'Walmart Moraine',
    addressLine: '1701 W Dorothy Ln, Moraine, OH 45439',
    lat: 39.7058,
    lng: -84.2186,
    retailer: StoreRetailer.walmart,
  ),
  StoreLocation(
    id: 'target_harbor',
    name: 'Target Huber Heights',
    addressLine: '8201 Old Troy Pike, Huber Heights, OH 45424',
    lat: 39.8704,
    lng: -84.1362,
    retailer: StoreRetailer.target,
  ),
];

final Map<String, StoreLocation> storeLocationsById = {
  for (final store in storeLocations) store.id: store,
};

StoreLocation storeLocationById(String id) {
  final store = storeLocationsById[id];
  if (store == null) {
    throw ArgumentError.value(id, 'id', 'Unknown store location');
  }
  return store;
}

import 'dart:convert';
import 'dart:math';

import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  final OpenFuelService openFuelService = OpenFuelService();
  Map<int, GasStation> stations = {};

  setUp(() async {
    stations = await openFuelService.getCurrentPrices();
  });

  test('has gas stations', () async {
    expect(stations.values.length, greaterThan(1));
  });

  test('search within a radius', () async {
    List<int> ranges = [
      250,
      500,
      1000,
      2500,
      5000,
      10000,
      20000,
      50000,
      100000,
    ];

    for (int i = 0; i < ranges.length; i++) {
      expect(() {
        var query = SearchGasStation(
          location: LatLng(45.76415682101847, 4.840621053489836),
          searchRadiusMeters: ranges[i],
          fuelType: FuelType.e10,
        );
        GasStation result = openFuelService.findBestGasStation(stations, query);

        print('range: ${ranges[i]}');
        print('name: ${result.name}');
        print('address: ${result.address}');
        print('price: ${result.getFuelPriceByType(FuelType.e10)}');
      }, returnsNormally);
    }
  }, timeout: Timeout(Duration(minutes: 1)));

  test('22160003 has name "Intermarché"', () async {
    expect(stations[22160003]?.name, equals('Intermarché'));
  });

  test('serialize and deserialize stations', () {
    List<String> stationsSerialized = stations.values.map((e) => jsonEncode(e.toJson())).toList();
    List<GasStation> stationsDeserialized = stationsSerialized.map((e) => GasStation.fromJson(jsonDecode(e))).toList();
    expect(stationsDeserialized.length, equals(stations.length));
    expect(stationsDeserialized[0].id, stations.values.first.id);
  });

  test('serialize and deserialize search', () {
    var query = SearchGasStation(
      location: LatLng(45.76415682101847, 4.840621053489836),
      searchRadiusMeters: 1000,
      fuelType: FuelType.e10,
    );
    var queryUnserialized = SearchGasStation.fromJson(query.toJson());
    expect(queryUnserialized.location.latitude, equals(query.location.latitude));
    expect(queryUnserialized.location.longitude, equals(query.location.longitude));
    expect(queryUnserialized.searchRadiusMeters, equals(query.searchRadiusMeters));
    expect(queryUnserialized.fuelType, equals(query.fuelType));
  });
}

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  final dio = Dio();
  final OpenFuelFrService openFuelFR = OpenFuelFrService(GasStationNameService(dio), PriceStatisticsService(), dio);
  Map<int, GasStation> stations = {};

  setUp(() async {
    stations = await openFuelFR.fetchInstantPrices();
  });

  test('has gas stations', () async {
    expect(stations.values.length, greaterThan(1));
  });

  test('search within a radius', () async {
    final SearchGasStation search = SearchGasStation();
    search.setGasStations(stations);

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
        GasStation result = search.findCheapestInRange(
          LatLng(45.76415682101847, 4.840621053489836),
          fuelType: FuelType.e10,
          searchRadius: ranges[i],
        );

        print('range: ${ranges[i]}');
        print('name: ${result.name}');
        print('address: ${result.address}');
        print('price: ${result.getFuelPriceByType(FuelType.e10)}');
      }, returnsNormally);
    }
  }, timeout: Timeout(Duration(minutes: 1)));

  test('get statistics', () async {
    expect(openFuelFR.statistics.e10, greaterThan(0));
    expect(openFuelFR.statistics.e10, lessThan(2.5)); // for now...

    expect(openFuelFR.statistics.e85, greaterThan(0));
    expect(openFuelFR.statistics.e85, lessThan(2.5));

    expect(openFuelFR.statistics.gazole, greaterThan(0));
    expect(openFuelFR.statistics.gazole, lessThan(2.5));
  });

  test('22160003 has name "Intermarché"', () async {
    expect(stations[22160003]?.name, equals('Intermarché'));
  });
}

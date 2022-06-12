import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  Map<int, GasStation> stations = {};

  setUp(() async {
    stations = await openFuelFR.getInstantPrices();
  });

  test('has gas stations', () async {
    expect(stations.values.length, greaterThan(1));
  });

  test('search', () async {
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
      GasStation result = search.findCheapestInRange(
        LatLng(45.76415682101847, 4.840621053489836),
        fuelType: FuelType.e10,
        searchRadius: ranges[i],
      );

      print('range: ${ranges[i]}');
      print('name: ${result.name}');
      print('address: ${result.address}');
      print('price: ${result.getFuelPriceByType(FuelType.e10)}');
    }
  });
}

import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/model/gs_search_result.dart';
import 'package:test/test.dart';

void main() async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  List<GasStation> gasStations = [];

  setUp(() async {
    gasStations = await openFuelFR.getInstantPrices();
  });

  test('has gas stations', () async {
    expect(gasStations.length, greaterThan(1));
  });

  test('search', () async {
    final SearchGasStation search = SearchGasStation(gasStations);

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
      SearchResult result = search.findCheapestInRange(
          LatLng(45.76415682101847, 4.840621053489836),
          fuelType: FuelType.e10,
          searchRadius: ranges[i]);
      String name = await openFuelFR.getGasStationName(result.id);

      print('range: ${ranges[i]}');
      print('distance: ${result.distance}');
      print('name: $name');
      print('address: ${result.address}');
      print('price: ${result.getFuelPriceByType(FuelType.e10)}');
    }
  });
}

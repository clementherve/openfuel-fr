@Tags(['network'])
library;

import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

/// Hits the real opendata feed. Excluded from the default run:
///   dart test test/network
void main() {
  final OpenFuelService openFuelService = OpenFuelService();
  late Map<int, GasStation> stations;

  setUpAll(() async {
    stations = await openFuelService.getCurrentPrices();
  });

  tearDownAll(() => openFuelService.close());

  test('the feed returns thousands of stations', () {
    expect(stations.length, greaterThan(5000));
  });

  test('every station has a position and at least one price', () {
    expect(stations.values.every((s) => s.hasPosition && s.fuelPrices.isNotEmpty), isTrue);
  });

  test('prices are plausible euro amounts', () {
    final List<double> prices = stations.values.expand((s) => s.fuelPrices).map((f) => f.price).toList();
    expect(prices.every((p) => p > 0.1 && p < 10), isTrue, reason: 'a price fell outside 0.10-10.00 EUR');
  });

  test('most stations are named', () {
    final int named = stations.values.where((s) => s.name != '-').length;
    expect(named / stations.length, greaterThan(0.5));
  });

  test('national averages are plausible', () {
    final FuelPriceStatistics statistics = openFuelService.getPriceStatistics();
    expect(statistics.e10, inInclusiveRange(1.0, 3.0));
    expect(statistics.gazole, inInclusiveRange(1.0, 3.0));
  });

  test('a search around Lyon finds something', () {
    final SearchGasStation query = SearchGasStation(
      location: LatLng(45.76415682101847, 4.840621053489836),
      searchRadiusMeters: 5000,
      fuelType: FuelType.e10,
    );

    final List<GasStation> results = openFuelService.findGasStations(stations, query);
    expect(results, isNotEmpty);
    expect(openFuelService.findBestGasStation(stations, query).id, equals(results.first.id));
  });
}

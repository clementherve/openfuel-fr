import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

/// Lyon, roughly. Distances below are measured from here.
final LatLng _center = LatLng(45.75892, 4.86148);

GasStation _station(
  int id, {
  required LatLng position,
  required Map<String, double> prices,
  bool alwaysOpen = false,
  Duration age = const Duration(minutes: 5),
}) {
  final DateTime updated = DateTime.now().subtract(age);
  return GasStation(
    id,
    position,
    'address $id',
    'Lyon',
    alwaysOpen,
    const [],
    prices.entries.map((e) => FuelPrice(e.key, updated, e.value)).toList(),
    name: 'station $id',
  );
}

/// Moves [from] north by [meters], close enough at these distances.
LatLng _north(LatLng from, double meters) => LatLng(from.latitude + meters / 111320, from.longitude);

void main() {
  late SearchGasStationService service;
  late Map<int, GasStation> stations;

  setUp(() {
    stations = {
      // 500m away, cheapest E10 overall
      1: _station(1, position: _north(_center, 500), prices: {FuelType.e10: 1.50, FuelType.gazole: 1.90}),
      // 2km away, dearer but open around the clock
      2: _station(2, position: _north(_center, 2000), prices: {FuelType.e10: 1.60}, alwaysOpen: true),
      // 300m away, dearest, no E10 at all
      3: _station(3, position: _north(_center, 300), prices: {FuelType.gazole: 1.70}),
      // 50km away, absurdly cheap, should never win a local search
      4: _station(4, position: _north(_center, 50000), prices: {FuelType.e10: 0.90}),
      // next door but quoting a week-old price
      5: _station(5, position: _north(_center, 100), prices: {FuelType.e10: 1.00}, age: const Duration(days: 7)),
    };
    service = SearchGasStationService.station(stations);
  });

  SearchGasStation search({
    LatLng? location,
    int radius = 3000,
    String fuelType = FuelType.e10,
    bool alwaysOpen = false,
    List<int> ids = const [],
  }) {
    return SearchGasStation(
      location: location ?? _center,
      searchRadiusMeters: radius,
      fuelType: fuelType,
      alwaysOpen: alwaysOpen,
      constrainingIds: ids,
    );
  }

  group('findInRange', () {
    test('returns matching stations cheapest first', () {
      expect(service.findInRange(search()).map((s) => s.id), equals([1, 2]));
    });

    test('excludes stations that do not sell the fuel', () {
      expect(service.findInRange(search()).map((s) => s.id), isNot(contains(3)));
      expect(service.findInRange(search(fuelType: FuelType.gazole)).map((s) => s.id), equals([3, 1]));
    });

    test('excludes stale prices', () {
      // station 5 is the closest and the cheapest, but a week out of date
      expect(service.findInRange(search()).map((s) => s.id), isNot(contains(5)));
    });

    test('excludes stations beyond the radius', () {
      expect(service.findInRange(search(radius: 1000)).map((s) => s.id), equals([1]));
    });

    test('applies the always-open filter strictly', () {
      expect(service.findInRange(search(alwaysOpen: true)).map((s) => s.id), equals([2]));
    });

    test('applies the favourites filter strictly', () {
      expect(service.findInRange(search(ids: [2])).map((s) => s.id), equals([2]));
    });

    test('returns nothing rather than a bad match', () {
      expect(service.findInRange(search(radius: 50, ids: [4])), isEmpty);
    });
  });

  group('findCheapestInRange', () {
    test('picks the cheapest station inside the radius', () {
      expect(service.findCheapestInRange(search()).id, equals(1));
    });

    test('ignores a far cheaper station outside the radius', () {
      expect(service.findCheapestInRange(search()).id, isNot(equals(4)));
    });

    test('falls back to the closest station when none is in range', () {
      // nothing within 50m, station 1 is the closest fresh E10 seller
      expect(service.findCheapestInRange(search(radius: 50)).id, equals(1));
    });

    test('relaxes the always-open filter rather than returning nothing', () {
      final Map<int, GasStation> noneAlwaysOpen = {1: stations[1]!, 3: stations[3]!};
      final result = SearchGasStationService.station(noneAlwaysOpen).findCheapestInRange(search(alwaysOpen: true));
      expect(result.id, equals(1));
    });

    test('throws when no station sells the fuel at all', () {
      expect(
        () => SearchGasStationService.station({3: stations[3]!}).findCheapestInRange(search()),
        throwsA(isA<NoStationFoundException>()),
      );
    });
  });

  group('distances', () {
    test('are recomputed when the search moves', () {
      // a first search caches distances around the centre
      expect(service.findCheapestInRange(search()).id, equals(1));
      expect(service.distance(1), closeTo(500, 10));

      // searching from next to station 4 must not reuse them
      final LatLng faraway = _north(_center, 50000);
      expect(service.findCheapestInRange(search(location: faraway, radius: 1000)).id, equals(4));
      expect(service.distance(4), lessThan(50));
    });

    test('are dropped when the station set is replaced', () {
      service.findCheapestInRange(search());
      expect(service.distances, isNotEmpty);

      service.setGasStations(stations);
      expect(service.distances, isEmpty);
    });

    test('treat a station without coordinates as infinitely far', () {
      final GasStation nowhere = _station(6, position: LatLng(0, 0), prices: {FuelType.e10: 0.01});
      final search6 = SearchGasStationService.station({...stations, 6: nowhere});
      expect(search6.findInRange(search()).map((s) => s.id), isNot(contains(6)));
    });
  });

  group('PriceStatisticsService', () {
    test('averages each fuel over the stations that sell it', () {
      final PriceStatisticsService statistics = PriceStatisticsService()..computeGlobalStatistics(stations);

      // E10: 1.50, 1.60, 0.90, 1.00 over four stations, not five
      expect(statistics.globalStatistics.e10, closeTo((1.50 + 1.60 + 0.90 + 1.00) / 4, 0.0001));
      // Gazole: 1.90 and 1.70 over two stations
      expect(statistics.globalStatistics.gazole, closeTo((1.90 + 1.70) / 2, 0.0001));
    });

    test('reports zero for a fuel nobody sells', () {
      final PriceStatisticsService statistics = PriceStatisticsService()..computeGlobalStatistics(stations);
      expect(statistics.globalStatistics.gplc, equals(0));
      expect(statistics.globalStatistics.byType(FuelType.gplc), equals(0));
    });

    test('handles an empty station set', () {
      final PriceStatisticsService statistics = PriceStatisticsService()..computeGlobalStatistics({});
      expect(statistics.globalStatistics.e10, equals(0));
    });
  });
}

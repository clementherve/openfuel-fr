import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStation {
  late List<GasStation> _gasStations;
  late List<SearchResult> _results = [];
  late final Map<int, double> _distances = {};

  SearchGasStation(this._gasStations);
  SearchGasStation.empty();

  void setGasStations(final List<GasStation> gasStations) {
    print('setGasStations: ${gasStations.length}');
    _gasStations = gasStations;
  }

  double distance(int id) => _distances[id] ?? double.infinity;
  Map<int, double> get distances => _distances;

  List<SearchResult> results() => _gasStations.map((e) {
        SearchResult sr = SearchResult(e);
        sr.distance = distance(e.id);
        return sr;
      }).toList();

  /// return
  /// the distance if none of the args are null
  /// 0 if one of the arguments are null
  double _distance(final LatLng position, final LatLng? center) {
    if (position.latitude == 0 || position.longitude == 0 || center == null) {
      return double.infinity;
    }
    return SphericalUtil.computeDistanceBetween(center, position).toDouble();
  }

  List<SearchResult> findGasStationsDistance(
    LatLng center, {
    required int searchRadius,
    final String? fuelType,
    final Duration lastUpdated = const Duration(days: 1),
  }) {
    print('_gasStations.length: ${_gasStations.length}');
    _results = _gasStations.map((e) => SearchResult(e)).toList();

    print('_results.length: ${_results.length}');

    _results = _results.where((gs) {
      final double distance = _distance(gs.position, center);
      // final bool inRange = _isInRange(distance, searchRadius);

      final bool hasFuelCategory = (fuelType == null)
          ? true
          : gs.getAvailableFuelTypes().contains(fuelType);

      final bool isFresh = (hasFuelCategory)
          ? DateTime.now().difference(gs.fuels
                  .firstWhere((fuel) => fuel.type == fuelType)
                  .lastUpdated) <
              lastUpdated
          : false;

      // save the distance
      _distances[gs.id] = distance;

      // inRange &&
      return hasFuelCategory && isFresh;
    }).toList();

    _results.sort(((a, b) => distance(a.id).compareTo(distance(b.id))));
    return _results;
  }

  SearchResult findCheapestInRange(LatLng center,
      {required String fuelType,
      required int searchRadius,
      final bool? alwaysOpen = false,
      final List<int>? constrainingIds,
      final Duration lastUpdated = const Duration(days: 1)}) {
    List<SearchResult> distanceSorted = findGasStationsDistance(
      center,
      searchRadius: searchRadius,
      fuelType: fuelType,
      lastUpdated: lastUpdated,
    );

    print('distanceSorted.length: ${distanceSorted.length}');

    if (constrainingIds != null) {
      final List<SearchResult> tmp = distanceSorted
          .where((station) => constrainingIds.contains(station.id))
          .toList();
      distanceSorted = tmp.isNotEmpty ? tmp : distanceSorted;
    }

    if (alwaysOpen != null) {
      final List<SearchResult> tmp = distanceSorted
          .where((station) => station.isAlwaysOpen == alwaysOpen)
          .toList();
      distanceSorted = tmp.isNotEmpty ? tmp : distanceSorted;
    }

    distanceSorted.first.distance = distance(distanceSorted.first.id);

    if (distance(distanceSorted.first.id) > searchRadius) {
      // the closest gas station is outside of the search radius
      // return it
      return distanceSorted.first;
    } else {
      final List<SearchResult> inRange =
          distanceSorted.where((gs) => distance(gs.id) < searchRadius).toList();

      inRange.sort(((a, b) {
        return a
            .getFuelPriceByType(fuelType)
            .compareTo(b.getFuelPriceByType(fuelType));
      }));
      inRange.first.distance = distance(inRange.first.id);
      return inRange.first;
    }
  }
}

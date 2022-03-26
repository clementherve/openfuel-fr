import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/model/gs_search_result.dart';

class SearchGasStation {
  final List<GasStation> _gasStations;
  List<SearchResult> _results = [];
  final Map<int, double> _distances = {};

  SearchGasStation(this._gasStations);

  double distance(int id) => _distances[id] ?? double.infinity;

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
    final List<int>? constrainingIds,
    final Duration lastUpdated = const Duration(days: 1),
    final bool alwaysOpen = false,
  }) {
    _results = _gasStations.map((e) => SearchResult(e)).toList();
    _results = _results.where((gs) {
      final double distance = _distance(gs.position, center);
      // final bool inRange = _isInRange(distance, searchRadius);
      final bool mustBeAlwaysOpen = alwaysOpen
          ? gs.isAlwaysOpen
          : true; // true if alwaysOpen = false, sp.isAlwaysOpen else

      final bool hasFuelCategory = (fuelType == null)
          ? true
          : gs.getAvailableFuelTypes().contains(fuelType);

      final bool isFresh = (hasFuelCategory)
          ? DateTime.now().difference(gs.fuels
                  .firstWhere((fuel) => fuel.type == fuelType)
                  .lastUpdated) <
              lastUpdated
          : false;
      final bool correctId =
          constrainingIds == null ? true : constrainingIds.contains(gs.id);

      // save the distance
      _distances[gs.id] = distance;

      // inRange &&
      return mustBeAlwaysOpen && hasFuelCategory && isFresh && correctId;
    }).toList();

    _results.sort(((a, b) => distance(a.id).compareTo(distance(b.id))));
    return _results;
  }

  SearchResult findCheapestInRange(LatLng center,
      {required String fuelType,
      required int searchRadius,
      final bool alwaysOpen = false,
      final List<int>? constrainingIds,
      final Duration lastUpdated = const Duration(days: 1)}) {
    final List<SearchResult> distanceSorted = findGasStationsDistance(center,
        searchRadius: searchRadius,
        fuelType: fuelType,
        lastUpdated: lastUpdated,
        alwaysOpen: alwaysOpen);

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

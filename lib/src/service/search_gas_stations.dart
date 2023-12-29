import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/exception/no_station_found.dart';

class SearchGasStation {
  late Map<int, GasStation> _stations = {};
  late Map<int, double> _distances = {};

  SearchGasStation();

  SearchGasStation.station(final Map<int, GasStation> stations) {
    setGasStations(stations);
  }

  void setGasStations(final Map<int, GasStation> stations) {
    _stations = stations;
  }

  double distance(int id) => _distances[id] ?? double.infinity;
  Map<int, double> get distances => _distances;

  Map<int, GasStation> allStations() => _stations;

  /// return:
  /// - the distance if none of the args are null
  /// - 0 if one of the arguments are null
  static double _distance(final LatLng position, final LatLng? center) {
    if (position.latitude == 0 || position.longitude == 0 || center == null) {
      return double.infinity;
    }
    return SphericalUtil.computeDistanceBetween(center, position).toDouble();
  }

  /// return: the distance between each gas station and the given position
  Map<int, double> computeAllDistances(
    LatLng center,
    List<GasStation> stations,
  ) {
    _distances = stations.fold<Map<int, double>>({}, (previousValue, element) {
      return {
        ...previousValue,
        element.id: _distance(element.position, center),
      };
    });
    return _distances;
  }

  /// order stations by distance to the given position
  List<GasStation> _prefilter(
    LatLng center, {
    final String? fuelType,
    final Duration lastUpdated = const Duration(days: 1),
  }) {
    if (_distances.isEmpty) {
      _distances = computeAllDistances(center, _stations.values.toList());
    }

    final List<GasStation> filtered = _stations.values.where((gs) {
      final bool hasFuelCategory = (fuelType == null)
          ? true
          : gs.getAvailableFuelTypes().contains(fuelType);

      final bool isFresh = (hasFuelCategory)
          ? DateTime.now().difference(gs.fuels
                  .firstWhere((fuel) => fuel.type == fuelType)
                  .lastUpdated) <
              lastUpdated
          : false;

      return hasFuelCategory && isFresh;
    }).toList();

    filtered.sort(
      ((a, b) => (distances[a.id] ?? double.infinity)
          .compareTo(distances[b.id] ?? double.infinity)),
    );
    return filtered;
  }

  GasStation findCheapestInRange(
    LatLng center, {
    required String fuelType,
    required int searchRadius,
    final bool? alwaysOpen = false,
    final List<int>? constrainingIds,
    final Duration lastUpdated = const Duration(days: 1),
  }) {
    List<GasStation> prefilter = _prefilter(
      center,
      fuelType: fuelType,
      lastUpdated: lastUpdated,
    );

    if (prefilter.isEmpty) {
      throw NoStationFoundException();
    }

    if (constrainingIds != null) {
      final List<GasStation> tmp = prefilter
          .where((station) => constrainingIds.contains(station.id))
          .toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    if (alwaysOpen != null) {
      final List<GasStation> tmp = prefilter
          .where((station) => station.isAlwaysOpen == alwaysOpen)
          .toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    if (prefilter.isEmpty) {
      throw NoStationFoundException();
    }

    if (distance(prefilter.first.id) > searchRadius) {
      // the closest gas station is outside of the search radius
      // return it
      return prefilter.first;
    } else {
      final List<GasStation> inRange = prefilter
          .where(
            (station) => distance(station.id) < searchRadius,
          )
          .toList();

      // sort by price all the stations in range
      inRange.sort(
        ((a, b) {
          return a
              .getFuelPriceByType(fuelType)
              .compareTo(b.getFuelPriceByType(fuelType));
        }),
      );
      return inRange.first;
    }
  }
}

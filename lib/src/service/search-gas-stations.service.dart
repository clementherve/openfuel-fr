import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/exception/no-station-found.exception.dart';
import 'package:openfuelfr/src/model/search-gas-station.model.dart';

class SearchGasStationService {
  late Map<int, GasStation> _stations = {};
  late Map<int, double> _distances = {};

  SearchGasStationService();

  SearchGasStationService.station(final Map<int, GasStation> stations) {
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
    LatLng location, {
    final String? fuelType,
    final Duration lastUpdatedDays = const Duration(days: 1),
  }) {
    if (_distances.isEmpty) {
      _distances = computeAllDistances(location, _stations.values.toList());
    }

    final List<GasStation> filtered = _stations.values.where((gs) {
      final bool hasFuelCategory = (fuelType == null) ? true : gs.getAvailableFuelTypes().contains(fuelType);

      final bool isFresh = (hasFuelCategory)
          ? DateTime.now().difference(gs.fuelPrices.firstWhere((fuel) => fuel.type == fuelType).lastUpdated) < lastUpdatedDays
          : false;

      return hasFuelCategory && isFresh;
    }).toList();

    filtered.sort(
      ((a, b) => (distances[a.id] ?? double.infinity).compareTo(distances[b.id] ?? double.infinity)),
    );
    return filtered;
  }

  GasStation findCheapestInRange(SearchGasStation searchGasStation) {
    List<GasStation> prefilter = _prefilter(
      searchGasStation.location,
      fuelType: searchGasStation.fuelType,
      lastUpdatedDays: searchGasStation.lastUpdatedDays,
    );

    if (prefilter.isEmpty) {
      throw NoStationFoundException();
    }

    if (searchGasStation.constrainingIds.isNotEmpty) {
      final List<GasStation> tmp = prefilter.where((station) => searchGasStation.constrainingIds.contains(station.id)).toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    if (searchGasStation.alwaysOpen) {
      final List<GasStation> tmp = prefilter.where((station) => station.isAlwaysOpen == searchGasStation.alwaysOpen).toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    if (prefilter.isEmpty) {
      throw NoStationFoundException();
    }

    if (distance(prefilter.first.id) > searchGasStation.searchRadiusMeters) {
      // the closest gas station is outside of the search radius
      // return it
      return prefilter.first;
    } else {
      final List<GasStation> inRange = prefilter
          .where(
            (station) => distance(station.id) < searchGasStation.searchRadiusMeters,
          )
          .toList();

      // sort by price all the stations in range
      inRange.sort(
        ((a, b) {
          return a.getFuelPriceByType(searchGasStation.fuelType).compareTo(b.getFuelPriceByType(searchGasStation.fuelType));
        }),
      );
      return inRange.first;
    }
  }
}

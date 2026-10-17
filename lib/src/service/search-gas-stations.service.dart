import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStationService {
  Map<int, GasStation> _stations = {};
  Map<int, double> _distances = {};

  /// the centre the cached [_distances] were computed from, so a search
  /// made from a new position does not silently reuse the previous one
  LatLng? _distancesCenter;

  SearchGasStationService();

  SearchGasStationService.station(final Map<int, GasStation> stations) {
    setGasStations(stations);
  }

  void setGasStations(final Map<int, GasStation> stations) {
    _stations = stations;
    _distances = {};
    _distancesCenter = null;
  }

  double distance(int id) => _distances[id] ?? double.infinity;
  Map<int, double> get distances => _distances;

  Map<int, GasStation> allStations() => _stations;

  /// return:
  /// - the distance in meters between the two points
  /// - infinity when either point is unknown
  static double _distance(final LatLng position, final LatLng? center) {
    if (center == null || (position.latitude == 0 && position.longitude == 0)) {
      return double.infinity;
    }
    return SphericalUtil.computeDistanceBetween(center, position).toDouble();
  }

  /// return: the distance between each gas station and the given position
  Map<int, double> computeAllDistances(
    LatLng center,
    List<GasStation> stations,
  ) {
    _distances = {
      for (final station in stations) station.id: _distance(station.position, center),
    };
    _distancesCenter = center;
    return _distances;
  }

  bool _distancesAreStaleFor(final LatLng center) {
    final LatLng? cached = _distancesCenter;
    return _distances.isEmpty ||
        cached == null ||
        cached.latitude != center.latitude ||
        cached.longitude != center.longitude;
  }

  /// Stations selling [fuelType] with a fresh enough price, ordered by
  /// distance to [location].
  List<GasStation> _prefilter(
    LatLng location, {
    final String? fuelType,
    final Duration lastUpdatedDays = const Duration(days: 1),
  }) {
    if (_distancesAreStaleFor(location)) {
      computeAllDistances(location, _stations.values.toList());
    }

    final DateTime now = DateTime.now();

    final List<GasStation> filtered = _stations.values.where((gs) {
      if (fuelType == null) {
        // no fuel constraint: the station only has to quote something recent
        return gs.fuelPrices.any((fuel) => now.difference(fuel.lastUpdated) < lastUpdatedDays);
      }

      final FuelPrice? fuel = gs.getFuelByType(fuelType);
      return fuel != null && now.difference(fuel.lastUpdated) < lastUpdatedDays;
    }).toList();

    filtered.sort((a, b) => distance(a.id).compareTo(distance(b.id)));
    return filtered;
  }

  /// Every station matching [searchGasStation], cheapest first.
  ///
  /// Unlike [findCheapestInRange] this applies the filters strictly: an empty
  /// list means nothing matched.
  List<GasStation> findInRange(SearchGasStation searchGasStation) {
    final List<GasStation> candidates = _prefilter(
      searchGasStation.location,
      fuelType: searchGasStation.fuelType,
      lastUpdatedDays: searchGasStation.lastUpdatedDays,
    ).where((station) {
      if (distance(station.id) > searchGasStation.searchRadiusMeters) return false;
      if (searchGasStation.alwaysOpen && !station.isAlwaysOpen) return false;
      if (searchGasStation.constrainingIds.isNotEmpty && !searchGasStation.constrainingIds.contains(station.id)) {
        return false;
      }
      return true;
    }).toList();

    candidates.sort(
      (a, b) =>
          a.getFuelPriceByType(searchGasStation.fuelType).compareTo(b.getFuelPriceByType(searchGasStation.fuelType)),
    );
    return candidates;
  }

  /// The cheapest station matching [searchGasStation].
  ///
  /// The optional filters (favourites, always open) are relaxed rather than
  /// returning nothing, and when no station at all falls inside the radius the
  /// closest one outside it is returned.
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
      final List<GasStation> tmp =
          prefilter.where((station) => searchGasStation.constrainingIds.contains(station.id)).toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    if (searchGasStation.alwaysOpen) {
      final List<GasStation> tmp = prefilter.where((station) => station.isAlwaysOpen).toList();
      prefilter = tmp.isNotEmpty ? tmp : prefilter;
    }

    final List<GasStation> inRange =
        prefilter.where((station) => distance(station.id) <= searchGasStation.searchRadiusMeters).toList();

    if (inRange.isEmpty) {
      // nothing inside the radius: fall back to the closest station
      return prefilter.first;
    }

    inRange.sort(
      (a, b) =>
          a.getFuelPriceByType(searchGasStation.fuelType).compareTo(b.getFuelPriceByType(searchGasStation.fuelType)),
    );
    return inRange.first;
  }
}

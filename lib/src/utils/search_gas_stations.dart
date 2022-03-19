import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStation {
  final List<GasStation> _gasStations;

  SearchGasStation(this._gasStations);

  bool _isInRange(final LatLng position, final LatLng? center, int? maxRange) {
    if (position.latitude == 0 || position.longitude == 0) return false;
    if (center == null || maxRange == null) return true;
    num distance = SphericalUtil.computeDistanceBetween(center, position);
    bool inRange = distance < maxRange;

    return inRange;
  }

  List<GasStation> search(
    final String query, {
    final int? searchRadius,
    final LatLng? center,
    final String? fuelTypes,
    final bool alwaysOpen = false,
  }) {
    final String q = query.toLowerCase();
    return _gasStations.where((sp) {
      final bool inRange = _isInRange(
          sp.position, center, searchRadius); // true if any of them is null
      final bool queryMatch = sp.town.toLowerCase().contains(q) ||
          sp.address.toLowerCase().contains(q);
      final bool mustBeAlwaysOpen = alwaysOpen
          ? sp.isAlwaysOpen
          : true; // true if alwaysOpen = false, sp.isAlwaysOpen else

      bool hasFuelCategory = (fuelTypes == null)
          ? true
          : sp
              .getAvailableFuelTypes()
              .any((element) => fuelTypes.contains(element));

      return inRange && queryMatch && mustBeAlwaysOpen && hasFuelCategory;
    }).toList();
  }

  List<GasStation> findGasStationsInRange(
    LatLng center, {
    final int? searchRadius,
    final String? fuelType,
    final List<int>? constrainingIds,
    final Duration lastUpdated = const Duration(days: 1),
    final bool alwaysOpen = false,
  }) {
    return _gasStations.where((sp) {
      final bool inRange = _isInRange(
          sp.position, center, searchRadius); // true if any of them is null
      final bool mustBeAlwaysOpen = alwaysOpen
          ? sp.isAlwaysOpen
          : true; // true if alwaysOpen = false, sp.isAlwaysOpen else

      final bool hasFuelCategory = (fuelType == null)
          ? true
          : sp.getAvailableFuelTypes().contains(fuelType);

      final bool isFresh = (hasFuelCategory)
          ? DateTime.now().difference(sp.fuels
                  .firstWhere((fuel) => fuel.type == fuelType)
                  .lastUpdated) <
              lastUpdated
          : false;
      final bool correctId =
          constrainingIds == null ? true : constrainingIds.contains(sp.id);

      return inRange &&
          mustBeAlwaysOpen &&
          hasFuelCategory &&
          isFresh &&
          correctId;
    }).toList();
  }

  /// Can be null if no stations are in range
  GasStation? findCheapestInRange(LatLng center,
      {required String fuelType,
      final int? searchRadius,
      final bool alwaysOpen = false,
      final List<int>? constrainingIds,
      final Duration lastUpdated = const Duration(days: 1)}) {
    final List<GasStation> inRange = findGasStationsInRange(center,
        searchRadius: searchRadius,
        fuelType: fuelType,
        lastUpdated: lastUpdated,
        alwaysOpen: alwaysOpen);
    if (inRange.isEmpty) return null;
    inRange.sort(((a, b) => a
        .getFuelPriceByType(fuelType)
        .compareTo(b.getFuelPriceByType(fuelType))));
    return inRange.first;
  }
}

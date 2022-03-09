import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:logging/logging.dart';

class SellingPointSearch {
  final List<SellingPoint> _sellingPoints;
  final LatLng? center;
  final _logger = Logger('OpenFuelFR');

  SellingPointSearch(this._sellingPoints, {this.center}) {
    _logger.config(Level.ALL);

    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  bool _isInRange(final LatLng position, int? maxRange) {
    if (center == null || maxRange == null) return true;
    return SphericalUtil.computeDistanceBetween(center!, position) / 1000.0 <
        maxRange;
  }

  List<SellingPoint> search(
    final String query, {
    final int? searchRadius,
    final List<FuelType>? fuelTypes,
    final bool alwaysOpen = false,
  }) {
    final Stopwatch searchSW = Stopwatch()..start(); // debug

    final String q = query.toLowerCase();
    final List<SellingPoint> results = _sellingPoints.where((sp) {
      final bool inRange =
          _isInRange(sp.position, searchRadius); // true if any of them is null
      final bool queryMatch = sp.town.toLowerCase().contains(q) ||
          sp.address.toLowerCase().contains(q);
      final bool mustBeAlwaysOpen = alwaysOpen
          ? sp.isAlwaysOpen
          : true; // true if alwaysOpen = false, sp.isAlwaysOpen else

      // TODO: filter by fuel category

      return inRange && queryMatch && mustBeAlwaysOpen;
    }).toList();
    _logger.info('search: ${searchSW.elapsed.inMilliseconds}ms'); // debug

    return results;
  }
}

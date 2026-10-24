import 'dart:collection';

/// The display name of each station, keyed by its official id.
///
/// The opendata feed carries no brand, so this comes from a side list. It is a
/// plain value so it can be cached and passed to an isolate.
class GasStationNames {
  final Map<int, String> _names;

  const GasStationNames(this._names);

  const GasStationNames.empty() : _names = const {};

  /// A read-only view of the id → name map.
  Map<int, String> get asMap => UnmodifiableMapView(_names);
  bool get isEmpty => _names.isEmpty;
  bool get isNotEmpty => _names.isNotEmpty;

  /// The station's name, or '-' when unknown.
  String nameOf(final int stationId) {
    final String? name = _names[stationId];
    return name == null || name.isEmpty ? '-' : name;
  }
}

/// The brand/name of each station, keyed by station id as a string.
///
/// The opendata feed carries no brand, so this comes from a side list. It is a
/// plain value so it can be cached and passed to an isolate.
class GasStationNames {
  final Map<int, String> _names;

  const GasStationNames(this._names);

  const GasStationNames.empty() : _names = const {};

  Map<int, String> get asMap => _names;
  bool get isEmpty => _names.isEmpty;
  bool get isNotEmpty => _names.isNotEmpty;

  /// The station's own name, falling back to its brand, then '-'.
  String nameOf(final int stationId) {
    return _names[stationId] ?? '-';
  }
}

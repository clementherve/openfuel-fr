/// The brand/name of each station, keyed by station id as a string.
///
/// The opendata feed carries no brand, so this comes from a side list. It is a
/// plain value so it can be cached and passed to an isolate.
class GasStationNames {
  final Map<String, dynamic> _names;

  const GasStationNames(this._names);

  const GasStationNames.empty() : _names = const {};

  Map<String, dynamic> get asMap => _names;
  bool get isEmpty => _names.isEmpty;
  bool get isNotEmpty => _names.isNotEmpty;

  Map<String, dynamic>? _entry(final int stationId) {
    final dynamic entry = _names[stationId.toString()];
    return entry is Map ? Map<String, dynamic>.from(entry) : null;
  }

  /// The brand (`Total`, `Intermarché`, ...), or '-' when unknown.
  String brandOf(final int stationId) => _entry(stationId)?['marque'] as String? ?? '-';

  /// The station's own name, falling back to its brand, then '-'.
  String nameOf(final int stationId) {
    final Map<String, dynamic>? entry = _entry(stationId);
    return entry?['nom'] as String? ?? entry?['marque'] as String? ?? '-';
  }
}

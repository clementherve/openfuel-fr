class NoStationFoundException implements Exception {
  @override
  String toString() => 'NoStationFoundException: no gas station matched the search';
}

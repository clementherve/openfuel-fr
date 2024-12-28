import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStation {
  LatLng location;
  int searchRadiusMeters;
  String fuelType;
  bool alwaysOpen;
  List<int> constrainingIds;
  Duration lastUpdatedDays;

  SearchGasStation({
    required this.location,
    required this.searchRadiusMeters,
    required this.fuelType,
    this.alwaysOpen = false,
    this.constrainingIds = const [],
    this.lastUpdatedDays = const Duration(days: 1),
  });
}

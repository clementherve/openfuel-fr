import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStation {
  late LatLng location;
  late int searchRadiusMeters;
  late String fuelType;
  late bool alwaysOpen;
  late List<int> constrainingIds;
  late Duration lastUpdatedDays;

  SearchGasStation({
    required this.location,
    required this.searchRadiusMeters,
    required this.fuelType,
    this.alwaysOpen = false,
    this.constrainingIds = const [],
    this.lastUpdatedDays = const Duration(days: 1),
  });

  SearchGasStation.fromJson(Map<String, dynamic> json) {
    location = LatLng(json['location']['lat'], json['location']['lng']);
    searchRadiusMeters = json['search_radius_meters'];
    fuelType = json['fuel_type'];
    alwaysOpen = json['always_open'];
    constrainingIds = json['constraining_ids'];
    lastUpdatedDays = Duration(days: json['last_updated_days']);
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'search_radius_meters': searchRadiusMeters,
      'fuel_type': fuelType,
      'always_open': alwaysOpen,
      'constraining_ids': constrainingIds,
      'last_updated_days': lastUpdatedDays.inDays,
    };
  }
}

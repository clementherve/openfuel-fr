import 'package:openfuelfr/openfuelfr.dart';

class SearchGasStation {
  final LatLng location;
  final int searchRadiusMeters;
  final String fuelType;
  final bool alwaysOpen;
  final List<int> constrainingIds;
  final Duration lastUpdatedDays;

  SearchGasStation({
    required this.location,
    required this.searchRadiusMeters,
    required this.fuelType,
    this.alwaysOpen = false,
    this.constrainingIds = const [],
    this.lastUpdatedDays = const Duration(days: 1),
  });

  factory SearchGasStation.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> location = Map<String, dynamic>.from(json['location'] as Map);
    return SearchGasStation(
      location: LatLng(
        (location['lat'] as num).toDouble(),
        (location['lng'] as num).toDouble(),
      ),
      searchRadiusMeters: json['search_radius_meters'] as int,
      fuelType: json['fuel_type'] as String,
      alwaysOpen: json['always_open'] as bool? ?? false,
      constrainingIds: List<int>.from(json['constraining_ids'] as List? ?? const []),
      // stored in seconds so sub-day freshness windows survive a round-trip
      lastUpdatedDays: Duration(seconds: json['last_updated_seconds'] as int? ?? const Duration(days: 1).inSeconds),
    );
  }

  SearchGasStation copyWith({
    LatLng? location,
    int? searchRadiusMeters,
    String? fuelType,
    bool? alwaysOpen,
    List<int>? constrainingIds,
    Duration? lastUpdatedDays,
  }) {
    return SearchGasStation(
      location: location ?? this.location,
      searchRadiusMeters: searchRadiusMeters ?? this.searchRadiusMeters,
      fuelType: fuelType ?? this.fuelType,
      alwaysOpen: alwaysOpen ?? this.alwaysOpen,
      constrainingIds: constrainingIds ?? this.constrainingIds,
      lastUpdatedDays: lastUpdatedDays ?? this.lastUpdatedDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'search_radius_meters': searchRadiusMeters,
      'fuel_type': fuelType,
      'always_open': alwaysOpen,
      'constraining_ids': constrainingIds,
      'last_updated_seconds': lastUpdatedDays.inSeconds,
    };
  }
}

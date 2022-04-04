import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/src/model/opening_days.dart';
import 'package:openfuelfr/src/model/fuel.dart';

class GasStation {
  final int _id;
  final LatLng _position;
  final String _address;
  final String _town;
  final bool _isAlwaysOpen;
  final List<OpeningDays> _openingDays;
  final List<Fuel> _fuelPrices;

  GasStation(
    this._id,
    this._position,
    this._address,
    this._town,
    this._isAlwaysOpen,
    this._openingDays,
    this._fuelPrices,
  );

  int get id => _id;
  LatLng get position => _position;
  String get address => _address;
  String get town => _town;
  bool get isAlwaysOpen => _isAlwaysOpen;
  List<OpeningDays> get openingDays => _openingDays;
  List<Fuel> get fuels => _fuelPrices;

  /// return all fuel types
  /// values in FuelType
  List<String> getAvailableFuelTypes() {
    return _fuelPrices.map((fuel) => fuel.type).toList();
  }

  double getFuelPriceByType(final String fuelType) {
    return _fuelPrices
        .firstWhere((fuel) => fuel.type == fuelType,
            orElse: (() => Fuel.empty()))
        .price;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'position': [
        _position.latitude,
        _position.longitude,
      ],
      'address': _address,
      'town': _town,
      'is_always_open': _isAlwaysOpen,
      'prices': _fuelPrices.map((e) => e.toJson()).toList(),
      'opening_days': _openingDays.map((e) => e.toJson()).toList()
    };
  }
}

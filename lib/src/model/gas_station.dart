import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/src/model/opening_days.dart';
import 'package:openfuelfr/src/model/fuel.dart';

class GasStation {
  late int _id;
  late String name;
  late LatLng _position;
  late String _address;
  late String _town;
  late bool _isAlwaysOpen;
  late List<OpeningDays> _openingDays;
  late List<Fuel> _fuelPrices;

  GasStation(
    this._id,
    this._position,
    this._address,
    this._town,
    this._isAlwaysOpen,
    this._openingDays,
    this._fuelPrices,
  );

  GasStation.fromJSON(Map<String, dynamic> json) {
    _id = json['id'];
    name = json['name'];
    _position = LatLng(
      json['position'][0],
      json['position'][1],
    );
    _address = json['address'];
    _town = json['town'];
    _isAlwaysOpen = json['is_always_open'];
    _fuelPrices = json['prices'].map((priceJson) => Fuel.fromJSON(priceJson));
    _openingDays =
        json['opening_days'].map((dayJson) => OpeningDays.fromJSON(dayJson));
  }

  int get id => _id;
  LatLng get position => _position;
  String get address => _address;
  String get town => _town;
  bool get isAlwaysOpen => _isAlwaysOpen;
  List<OpeningDays> get openingDays => _openingDays;
  List<Fuel> get fuels => _fuelPrices;

  /// return all fuel types
  List<String> getAvailableFuelTypes() {
    return _fuelPrices.map((fuel) => fuel.type).toList();
  }

  double getFuelPriceByType(
    final String fuelType, {
    final double elseValue = double.infinity,
  }) {
    final Fuel fuel = _fuelPrices.firstWhere(
      (fuel) => fuel.type == fuelType,
      orElse: (() => Fuel.empty()),
    );
    return fuel.price == double.infinity ? elseValue : fuel.price;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': name,
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

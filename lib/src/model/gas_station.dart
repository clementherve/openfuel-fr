import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/src/model/opening_days.dart';
import 'package:openfuelfr/src/model/fuel.dart';

class GasStation {
  late int _id;
  late LatLng _position;
  late String _address;
  late String _town;

  late bool _isAlwaysOpen;

  late List<OpeningDays> _openingDays;
  late List<Fuel> _pricedFuel;

  GasStation(this._id, this._position, this._address, this._town,
      this._isAlwaysOpen, this._openingDays, this._pricedFuel);

  GasStation.empty() {
    _id = -1;
    _position = LatLng(45, 5);
    _address = '';
    _town = '';
    _isAlwaysOpen = false;
    _openingDays = [];
    _pricedFuel = [];
  }
  int get id => _id;

  LatLng get position => _position;
  String get address => _address;
  String get town => _town;

  bool get isAlwaysOpen => _isAlwaysOpen;

  List<OpeningDays> get openingDays => _openingDays;
  List<Fuel> get fuels => _pricedFuel;

  List<String> getAvailableFuelTypes() {
    return _pricedFuel.map((fuel) => fuel.type).toList();
  }

  double getFuelPriceByType(final String fuelType) {
    return _pricedFuel
        .firstWhere((fuel) => fuel.type == fuelType,
            orElse: (() => Fuel.empty()))
        .price;
  }

  Map toJson() {
    return {
      'id': _id,
      'position': [
        _position.latitude,
        _position.longitude,
      ],
      'address': _address,
      'town': _town,
      'is_always_open': _isAlwaysOpen,
      'prices': [_pricedFuel.map((e) => e.toJson())],
      'opening_days': [_openingDays.map((e) => e.toJson())]
    };
  }
}

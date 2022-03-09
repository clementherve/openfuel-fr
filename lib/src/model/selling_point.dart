import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:openfuelfr/src/model/opening_days.dart';
import 'package:openfuelfr/src/model/priced_fuel.dart';

class SellingPoint {
  late int _id;
  final LatLng _position;
  final String _address;
  final String _town;

  final bool _isAlwaysOpen;

  final List<OpeningDays> _openingDays;
  final List<PricedFuel> _pricedFuel;

  SellingPoint(this._position, this._address, this._town, this._isAlwaysOpen,
      this._openingDays, this._pricedFuel) {
    _id = Object.hash(_address, _town);
  }

  int get id => _id;

  LatLng get position => _position;
  String get address => _address;
  String get town => _town;

  bool get isAlwaysOpen => _isAlwaysOpen;

  List<OpeningDays> get openingDays => _openingDays;
  List<PricedFuel> get pricedFuel => _pricedFuel;

  List<String> getAvailableFuelTypes() {
    return _pricedFuel.map((fuel) => fuel.name).toList();
  }

  double getFuelPriceByType(final String fuelType) {
    return _pricedFuel
        .firstWhere((fuel) => fuel.name == fuelType,
            orElse: (() => PricedFuel.empty()))
        .price;
  }
}

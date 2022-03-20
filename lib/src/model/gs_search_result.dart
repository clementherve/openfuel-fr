import 'package:openfuelfr/openfuelfr.dart';

class SearchResult {
  late int _id;
  late LatLng _position;
  late String _address;
  late String _town;

  late bool _isAlwaysOpen;

  late List<OpeningDays> _openingDays;
  late List<Fuel> _pricedFuel;

  late double _distance;
  late String _name;

  SearchResult(
      this._id,
      this._position,
      this._distance,
      this._name,
      this._address,
      this._town,
      this._isAlwaysOpen,
      this._openingDays,
      this._pricedFuel);

  SearchResult.fromGasStation(final GasStation gs,
      {String? name, double? distance}) {
    _id = gs.id;
    _position = gs.position;
    _address = gs.address;
    _town = gs.town;
    _isAlwaysOpen = gs.isAlwaysOpen;
    _openingDays = gs.openingDays;
    _pricedFuel = gs.fuels;
    _distance = distance ?? double.infinity;
    _name = name ?? 'n/a';
  }

  int get id => _id;

  LatLng get position => _position;
  String get address => _address;
  String get town => _town;
  String get name => _name;
  double get distance => _distance;

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

  GasStation toGasStation() {
    return GasStation(_id, _position, _address, _town, _isAlwaysOpen,
        _openingDays, _pricedFuel);
  }

  Map toJson() {
    return {
      'id': _id,
      'position': [
        _position.latitude,
        _position.longitude,
      ],
      'distance': distance,
      'name': name,
      'address': _address,
      'town': _town,
      'is_always_open': _isAlwaysOpen,
      'prices': [_pricedFuel.map((e) => e.toJson())],
      'opening_days': [_openingDays.map((e) => e.toJson())]
    };
  }
}

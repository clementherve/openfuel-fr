class Fuel {
  late String _fuelType;
  late DateTime _lastUpdated;
  late double _price;
  Fuel(this._fuelType, this._lastUpdated, this._price);

  Fuel.empty() {
    _fuelType = '-';
    _lastUpdated = DateTime.parse('19700101');
    _price = -1;
  }

  String get type => _fuelType;
  DateTime get lastUpdated => _lastUpdated;
  bool get isFresh => DateTime.now().difference(_lastUpdated).inDays < 2;
  double get price => _price;

  Map toJson() {
    return {
      'fuel_type': type,
      'last_updated': lastUpdated.toString(),
      'price': price
    };
  }
}
class FuelPrice {
  late String _fuelType;
  late DateTime _lastUpdated;
  late double _price;
  FuelPrice(this._fuelType, this._lastUpdated, this._price);

  FuelPrice.empty() {
    _fuelType = '-';
    _lastUpdated = DateTime.parse('19700101');
    _price = double.infinity;
  }

  FuelPrice.fromJson(Map<String, dynamic> json) {
    _fuelType = json['fuel_type'];
    _lastUpdated = DateTime.parse(json['last_updated']);
    _price = json['price'] ?? 0;
  }

  String get type => _fuelType;
  DateTime get lastUpdated => _lastUpdated;
  bool get isFresh => DateTime.now().difference(_lastUpdated).inDays < 2;
  double get price => _price;

  Map<String, dynamic> toJson() {
    return {'fuel_type': type, 'last_updated': lastUpdated.toString(), 'price': price};
  }
}

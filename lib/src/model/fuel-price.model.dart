class FuelPrice {
  final String _fuelType;
  final DateTime _lastUpdated;
  final double _price;

  FuelPrice(this._fuelType, this._lastUpdated, this._price);

  factory FuelPrice.empty() => FuelPrice('-', DateTime.fromMillisecondsSinceEpoch(0), double.infinity);

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    final num? price = json['price'] as num?;
    return FuelPrice(
      json['fuel_type'] as String,
      DateTime.parse(json['last_updated'] as String),
      // an unknown price round-trips as null, not as a non-finite double
      // which `jsonEncode` refuses to write
      price?.toDouble() ?? double.infinity,
    );
  }

  String get type => _fuelType;
  DateTime get lastUpdated => _lastUpdated;
  double get price => _price;

  bool get isKnown => _price.isFinite;
  bool get isFresh => DateTime.now().difference(_lastUpdated).inDays < 2;

  Map<String, dynamic> toJson() {
    return {
      'fuel_type': _fuelType,
      'last_updated': _lastUpdated.toIso8601String(),
      'price': _price.isFinite ? _price : null,
    };
  }

  @override
  String toString() => '$_fuelType: ${_price.isFinite ? _price : 'n/a'}';
}

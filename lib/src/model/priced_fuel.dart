class PricedFuel {
  final String _name;
  final DateTime _lastUpdated;
  final double _price;
  PricedFuel(this._name, this._lastUpdated, this._price);

  String get name => _name;
  DateTime get lastUpdated => _lastUpdated;
  bool get isFresh => DateTime.now().difference(_lastUpdated).inDays < 2;
  double get price => _price;
}

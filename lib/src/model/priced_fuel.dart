class PricedFuel {
  late String _name;
  late DateTime _lastUpdated;
  late double _price;
  PricedFuel(this._name, this._lastUpdated, this._price);

  PricedFuel.empty() {
    _name = '-';
    _lastUpdated = DateTime.parse('19700101');
    _price = -1;
  }

  String get name => _name;
  DateTime get lastUpdated => _lastUpdated;
  bool get isFresh => DateTime.now().difference(_lastUpdated).inDays < 2;
  double get price => _price;
}

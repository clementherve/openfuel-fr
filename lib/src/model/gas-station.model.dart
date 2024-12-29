import 'package:openfuelfr/openfuelfr.dart';
import 'package:xml/xml.dart';

class GasStation {
  late int _id;
  late String name;
  late LatLng _position;
  late String _address;
  late String _town;
  late bool _isAlwaysOpen;
  late List<OpenDay> _openDays;
  late List<FuelPrice> _fuelPrices;

  GasStation(
    this._id,
    this._position,
    this._address,
    this._town,
    this._isAlwaysOpen,
    this._openDays,
    this._fuelPrices,
  );

  GasStation.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    name = json['name'];
    _position = LatLng(
      json['position'][0],
      json['position'][1],
    );
    _address = json['address'];
    _town = json['town'];
    _isAlwaysOpen = json['is_always_open'];
    _fuelPrices = json['prices'].map<FuelPrice>((priceJson) => FuelPrice.fromJson(priceJson)).toList();
    _openDays = json['open_days'].map<OpenDay>((dayJson) => OpenDay.fromJson(dayJson)).toList();
  }

  GasStation.fromXML(final XmlNode xml) {
    _id = int.parse(xml.getAttribute('id') ?? '0');

    _address = xml.getElement('adresse')?.innerText ?? '-';
    _town = xml.getElement('ville')?.innerText ?? '-';

    // see Q4 https://www.prix-carburants.gouv.fr/rubrique/opendata/
    _position = LatLng(double.parse(xml.getAttribute('latitude') ?? '0.0') / 100000, double.parse(xml.getAttribute('longitude') ?? '0.0') / 100000);

    _fuelPrices = xml.findAllElements('prix').map((e) {
      final String name = e.getAttribute('nom') ?? '-';
      final DateTime lastUpdated = DateTime.parse(e.getAttribute('maj') ?? '19700101');
      double price = double.parse(e.getAttribute('valeur') ?? '0.0');

      if (price > 500) {
        // pas pour les flux instantanés...
        price = price / 1000; // 	Prix en euros multiplié par 1000
      }

      return FuelPrice(name, lastUpdated, price);
    }).toList();

    _isAlwaysOpen = xml.getElement('horaires')?.getAttribute('automate-24-24') == '1';

    _openDays = xml.findAllElements('jour').map((e) {
      final String name = e.getAttribute('nom') ?? '-';
      final bool isOpen = e.getAttribute('ferme') == '';

      final String openingHour = e.getElement('horaire')?.getAttribute('ouverture') ?? (_isAlwaysOpen ? '00.00' : '-');
      final String closingHour = e.getElement('horaire')?.getAttribute('fermeture') ?? (_isAlwaysOpen ? '23.59' : '-');

      final OpeningHours openingHours = OpeningHours(openingHour, closingHour);

      return OpenDay(name, isOpen, openingHours);
    }).toList();
  }

  int get id => _id;
  LatLng get position => _position;
  String get address => _address;
  String get town => _town;
  bool get isAlwaysOpen => _isAlwaysOpen;
  List<OpenDay> get openingDay => _openDays;
  List<FuelPrice> get fuels => _fuelPrices;

  /// return all fuel types
  List<String> getAvailableFuelTypes() {
    return _fuelPrices.map((fuel) => fuel.type).toList();
  }

  double getFuelPriceByType(
    final String fuelType, {
    final double elseValue = double.infinity,
  }) {
    final FuelPrice fuel = _fuelPrices.firstWhere(
      (fuel) => fuel.type == fuelType,
      orElse: (() => FuelPrice.empty()),
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
      'open_days': _openDays.map((e) => e.toJson()).toList()
    };
  }
}

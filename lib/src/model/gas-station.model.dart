import 'package:openfuelfr/openfuelfr.dart';
import 'package:xml/xml.dart';

class GasStation {
  final int _id;
  String name;
  final LatLng _position;
  final String _address;
  final String _city;
  final String _postalCode;
  final bool _isAlwaysOpen;
  final List<String> _services;
  final List<OpenDay> _openDays;
  final List<FuelPrice> _fuelPrices;

  GasStation(
    this._id,
    this._position,
    this._address,
    this._city,
    this._isAlwaysOpen,
    this._openDays,
    this._fuelPrices, {
    this.name = '-',
    String postalCode = '-',
    List<String> services = const [],
  })  : _postalCode = postalCode,
        _services = services;

  factory GasStation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> position = json['position'] as List<dynamic>;
    return GasStation(
      json['id'] as int,
      LatLng((position[0] as num).toDouble(), (position[1] as num).toDouble()),
      json['address'] as String,
      json['city'] as String,
      json['is_always_open'] as bool,
      (json['open_days'] as List? ?? const [])
          .map((day) => OpenDay.fromJson(Map<String, dynamic>.from(day as Map)))
          .toList(),
      (json['prices'] as List? ?? const [])
          .map((price) => FuelPrice.fromJson(Map<String, dynamic>.from(price as Map)))
          .toList(),
      name: json['name'] as String? ?? '-',
      postalCode: json['postal_code'] as String? ?? '-',
      services: List<String>.from(json['services'] as List? ?? const []),
    );
  }

  /// Builds a station from a `<pdv>` node, or returns null when the node
  /// carries no usable identity (whitespace nodes, malformed entries).
  static GasStation? tryFromXml(final XmlNode xml) {
    final int? id = int.tryParse(xml.getAttribute('id') ?? '');
    if (id == null) {
      return null;
    }

    // see Q4 https://www.prix-carburants.gouv.fr/rubrique/opendata/
    // coordinates are expressed in degrees multiplied by 100000
    final double latitude = (double.tryParse(xml.getAttribute('latitude') ?? '') ?? 0.0) / 100000;
    final double longitude = (double.tryParse(xml.getAttribute('longitude') ?? '') ?? 0.0) / 100000;

    final bool isAlwaysOpen = xml.getElement('horaires')?.getAttribute('automate-24-24') == '1';

    return GasStation(
      id,
      LatLng(latitude, longitude),
      xml.getElement('adresse')?.innerText.trim() ?? '-',
      xml.getElement('ville')?.innerText.trim() ?? '-',
      isAlwaysOpen,
      _parseOpenDays(xml, isAlwaysOpen),
      _parseFuelPrices(xml),
      postalCode: xml.getAttribute('cp') ?? '-',
      services: xml.findAllElements('service').map((e) => e.innerText.trim()).toList(),
    );
  }

  static List<FuelPrice> _parseFuelPrices(final XmlNode xml) {
    return xml
        .findAllElements('prix')
        .map((e) {
          final String type = e.getAttribute('nom') ?? '-';
          final DateTime lastUpdated =
              DateTime.tryParse(e.getAttribute('maj') ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

          double price = double.tryParse(e.getAttribute('valeur') ?? '') ?? double.infinity;

          // the daily and yearly feeds express prices in euros multiplied by 1000,
          // the instant one does not
          if (price.isFinite && price > 500) {
            price = price / 1000;
          }

          return FuelPrice(type, lastUpdated, price);
        })
        .where((fuel) => fuel.type != '-' && fuel.isKnown)
        .toList();
  }

  static List<OpenDay> _parseOpenDays(final XmlNode xml, final bool isAlwaysOpen) {
    return xml.findAllElements('jour').map((e) {
      final String day = e.getAttribute('nom') ?? '-';
      // `ferme="1"` means closed, an empty attribute means open
      final bool isOpen = e.getAttribute('ferme') != '1';

      final XmlElement? hours = e.getElement('horaire');
      final String opening = hours?.getAttribute('ouverture') ?? (isAlwaysOpen ? '00.00' : '-');
      final String closing = hours?.getAttribute('fermeture') ?? (isAlwaysOpen ? '23.59' : '-');

      return OpenDay(day, isOpen, OpeningHours(opening, closing));
    }).toList();
  }

  int get id => _id;
  LatLng get position => _position;
  String get address => _address;
  String get city => _city;
  String get postalCode => _postalCode;
  bool get isAlwaysOpen => _isAlwaysOpen;
  List<String> get services => _services;
  List<OpenDay> get openDays => _openDays;
  List<FuelPrice> get fuelPrices => _fuelPrices;

  /// True when the feed gave real coordinates for this station.
  bool get hasPosition => _position.latitude != 0 || _position.longitude != 0;

  /// A label safe to show in a UI: the brand when known, the town otherwise.
  String get displayName {
    if (name != '-' && name.isNotEmpty) return name;
    return _city != '-' && _city.isNotEmpty ? _city : 'Station $_id';
  }

  /// return all fuel types this station sells
  List<String> getAvailableFuelTypes() => _fuelPrices.map((fuel) => fuel.type).toList();

  bool sells(final String fuelType) => _fuelPrices.any((fuel) => fuel.type == fuelType);

  FuelPrice? getFuelByType(final String fuelType) {
    for (final fuel in _fuelPrices) {
      if (fuel.type == fuelType) return fuel;
    }
    return null;
  }

  double getFuelPriceByType(
    final String fuelType, {
    final double elseValue = double.infinity,
  }) {
    final FuelPrice fuel = getFuelByType(fuelType) ?? FuelPrice.empty();
    return fuel.price.isFinite ? fuel.price : elseValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': name,
      'position': [_position.latitude, _position.longitude],
      'address': _address,
      'city': _city,
      'postal_code': _postalCode,
      'is_always_open': _isAlwaysOpen,
      'services': _services,
      'prices': _fuelPrices.map((e) => e.toJson()).toList(),
      'open_days': _openDays.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => '$displayName ($_id) - $_address, $_city';
}

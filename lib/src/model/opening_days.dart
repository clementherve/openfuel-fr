import 'package:openfuelfr/src/model/opening_hours.dart';

class OpeningDays {
  final String _day;
  final bool _isOpen;
  final OpeningHours _openingHours;

  OpeningDays(this._day, this._isOpen, this._openingHours);

  String get day => _day;
  bool get isOpen => _isOpen;
  OpeningHours get openingHours => _openingHours;

  Map<String, dynamic> toJson() {
    return {
      'day': _day,
      'is_open': _isOpen,
      'opening_hours': [_openingHours.toJson()]
    };
  }
}

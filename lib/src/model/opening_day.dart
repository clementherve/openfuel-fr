import 'package:openfuelfr/src/model/opening_hours.dart';

class OpenDay {
  late String _day;
  late bool _isOpen;
  late OpeningHours _openingHours;

  OpenDay(this._day, this._isOpen, this._openingHours);

  OpenDay.fromJSON(Map<String, dynamic> json) {
    _day = json['day'];
    _isOpen = json['is_open'];
    _openingHours = json['opening_hours'].map(
      (hour) => OpeningHours.fromJSON(hour),
    );
  }

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

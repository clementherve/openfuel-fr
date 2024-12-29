import 'package:openfuelfr/src/model/opening-hours.model.dart';

class OpenDay {
  late String _day;
  late bool _isOpen;
  late OpeningHours _openingHours;

  OpenDay(this._day, this._isOpen, this._openingHours);

  OpenDay.fromJson(Map<String, dynamic> json) {
    _day = json['day'];
    _isOpen = json['is_open'];
    _openingHours = OpeningHours.fromJson(json['opening_hours']);
  }

  String get day => _day;
  bool get isOpen => _isOpen;
  OpeningHours get openingHours => _openingHours;

  Map<String, dynamic> toJson() {
    return {'day': _day, 'is_open': _isOpen, 'opening_hours': _openingHours.toJson()};
  }
}

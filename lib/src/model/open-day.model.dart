import 'package:openfuelfr/src/model/opening-hours.model.dart';

class OpenDay {
  final String _day;
  final bool _isOpen;
  final OpeningHours _openingHours;

  OpenDay(this._day, this._isOpen, this._openingHours);

  factory OpenDay.fromJson(Map<String, dynamic> json) => OpenDay(
        json['day'] as String,
        json['is_open'] as bool,
        OpeningHours.fromJson(Map<String, dynamic>.from(json['opening_hours'] as Map)),
      );

  String get day => _day;
  bool get isOpen => _isOpen;
  OpeningHours get openingHours => _openingHours;

  Map<String, dynamic> toJson() {
    return {
      'day': _day,
      'is_open': _isOpen,
      'opening_hours': _openingHours.toJson(),
    };
  }
}

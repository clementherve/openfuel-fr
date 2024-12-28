class OpeningHours {
  late String _openingHour;
  late String _closingHour;
  OpeningHours(this._openingHour, this._closingHour);

  OpeningHours.fromJSON(Map<String, dynamic> json) {
    _openingHour = json['opening_hour'];
    _closingHour = json['closing_hour'];
  }

  String get openingHours => _openingHour;
  String get closingHour => _closingHour;

  Map toJson() {
    return {
      'opening_hour': _openingHour,
      'closing_hour': _closingHour,
    };
  }
}

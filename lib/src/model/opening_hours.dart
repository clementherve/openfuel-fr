class OpeningHours {
  final String _openingHour;
  final String _closingHour;
  OpeningHours(this._openingHour, this._closingHour);

  String get openingHours => _openingHour;
  String get closingHour => _closingHour;

  Map toJson() {
    return {
      'opening_hour': _openingHour,
      'closing_hour': _closingHour,
    };
  }
}

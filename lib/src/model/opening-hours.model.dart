class OpeningHours {
  final String _openingHour;
  final String _closingHour;

  OpeningHours(this._openingHour, this._closingHour);

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        json['opening_hour'] as String,
        json['closing_hour'] as String,
      );

  String get openingHour => _openingHour;
  String get closingHour => _closingHour;

  /// Kept for backwards compatibility; prefer [openingHour].
  @Deprecated('Use openingHour instead')
  String get openingHours => _openingHour;

  bool get isKnown => _openingHour != '-' && _closingHour != '-';

  Map<String, dynamic> toJson() {
    return {
      'opening_hour': _openingHour,
      'closing_hour': _closingHour,
    };
  }

  @override
  String toString() => '$_openingHour - $_closingHour';
}

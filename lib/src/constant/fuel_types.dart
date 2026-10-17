class FuelType {
  static const String gazole = 'Gazole';
  static const String sp95 = 'SP95';
  static const String sp98 = 'SP98';
  static const String gplc = 'GPLc';
  static const String e10 = 'E10';
  static const String e85 = 'E85';

  /// Every fuel type the opendata feed reports, in the feed's own order.
  static const List<String> all = [gazole, sp95, e85, gplc, e10, sp98];

  static bool isKnown(final String fuelType) => all.contains(fuelType);
}

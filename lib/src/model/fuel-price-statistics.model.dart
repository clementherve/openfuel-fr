import 'package:openfuelfr/src/constant/fuel_types.dart';

class FuelPriceStatistics {
  final double gazole;
  final double sp95;
  final double e10;
  final double sp98;
  final double gplc;
  final double e85;

  const FuelPriceStatistics({
    required this.e10,
    required this.gazole,
    required this.sp95,
    required this.sp98,
    required this.gplc,
    required this.e85,
  });

  const FuelPriceStatistics.zero()
      : gazole = 0.0,
        sp95 = 0.0,
        e10 = 0.0,
        sp98 = 0.0,
        gplc = 0.0,
        e85 = 0.0;

  /// The national average for [fuelType], or 0 when it is unknown.
  double byType(final String fuelType) {
    switch (fuelType) {
      case FuelType.gazole:
        return gazole;
      case FuelType.sp95:
        return sp95;
      case FuelType.sp98:
        return sp98;
      case FuelType.gplc:
        return gplc;
      case FuelType.e10:
        return e10;
      case FuelType.e85:
        return e85;
      default:
        return 0.0;
    }
  }

  Map<String, double> toMap() => {for (final type in FuelType.all) type: byType(type)};
}

import 'package:openfuelfr/openfuelfr.dart';

class PriceStatisticsService {
  FuelPriceStatistics _globalStatistics = FuelPriceStatistics.zero();

  /// Averages each fuel over the stations that actually sell it.
  ///
  /// Dividing by the whole station count instead would drag every average
  /// down towards zero, badly so for the rarer fuels such as GPLc.
  void computeGlobalStatistics(final Map<int, GasStation> stations) {
    final Map<String, double> sums = {for (final type in FuelType.all) type: 0.0};
    final Map<String, int> counts = {for (final type in FuelType.all) type: 0};

    for (final station in stations.values) {
      for (final fuel in station.fuelPrices) {
        if (!sums.containsKey(fuel.type) || !fuel.isKnown) continue;
        sums[fuel.type] = sums[fuel.type]! + fuel.price;
        counts[fuel.type] = counts[fuel.type]! + 1;
      }
    }

    double average(String type) => counts[type]! == 0 ? 0.0 : sums[type]! / counts[type]!;

    _globalStatistics = FuelPriceStatistics(
      e10: average(FuelType.e10),
      e85: average(FuelType.e85),
      gazole: average(FuelType.gazole),
      gplc: average(FuelType.gplc),
      sp95: average(FuelType.sp95),
      sp98: average(FuelType.sp98),
    );
  }

  FuelPriceStatistics get globalStatistics => _globalStatistics;

  // todo: compute stats by geographic areas
}

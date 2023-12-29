import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/model/fuel_price_statistics.dart';

class PriceStatisticsService {
  late FuelPriceStatistics _globalStatistics = FuelPriceStatistics.zero();

  void computeGlobalStatistics(final List<GasStation> stations) {
    _globalStatistics = stations.fold<FuelPriceStatistics>(FuelPriceStatistics.zero(), (prev, station) {
      return FuelPriceStatistics(
        e10: prev.e10 + station.getFuelPriceByType(FuelType.e10, elseValue: 0),
        gazole: prev.gazole + station.getFuelPriceByType(FuelType.gazole, elseValue: 0),
        sp95: prev.sp95 + station.getFuelPriceByType(FuelType.sp95, elseValue: 0),
        sp98: prev.sp98 + station.getFuelPriceByType(FuelType.sp98, elseValue: 0),
        gplc: prev.gplc + station.getFuelPriceByType(FuelType.gplc, elseValue: 0),
        e85: prev.e85 + station.getFuelPriceByType(FuelType.e85, elseValue: 0),
      );
    });

    _globalStatistics.e10 /= stations.length;
    _globalStatistics.e85 /= stations.length;
    _globalStatistics.gazole /= stations.length;
    _globalStatistics.gplc /= stations.length;
    _globalStatistics.sp95 /= stations.length;
    _globalStatistics.sp98 /= stations.length;
  }

  FuelPriceStatistics get globalStatistics => _globalStatistics;

  // todo: compute stats by geographic areas
}

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';

import 'package:openfuelfr/src/service/get-gas-station-prices.service.dart';

export 'package:maps_toolkit/maps_toolkit.dart' show LatLng;

export 'src/constant/fuel_types.dart' show FuelType;
export 'src/exception/http.exception.dart' show HttpException;
export 'src/exception/no-station-found.exception.dart' show NoStationFoundException;
export 'src/model/fuel-price-statistics.model.dart' show FuelPriceStatistics;
export 'src/model/fuel-price.model.dart' show FuelPrice;
export 'src/model/gas-station.model.dart' show GasStation;
export 'src/model/open-day.model.dart' show OpenDay;
export 'src/model/opening-hours.model.dart' show OpeningHours;
export 'src/model/search-gas-station.model.dart' show SearchGasStation;
export 'src/service/get-gas-station-names.service.dart';
export 'src/service/price-statistics.service.dart' show PriceStatisticsService;
export 'src/service/search-gas-stations.service.dart' show SearchGasStationService;

class OpenFuelService {
  final Dio _dio;
  late final GetGasStationNamesService _getGasStationNamesService;
  late final GetGasStationPricesService _getGasStationPricesService;
  final SearchGasStationService _searchGasStationService = SearchGasStationService();
  final PriceStatisticsService _priceStatisticsService = PriceStatisticsService();

  OpenFuelService({Dio? dio}) : _dio = dio ?? Dio() {
    _getGasStationNamesService = GetGasStationNamesService(_dio);
    _getGasStationPricesService = GetGasStationPricesService(_getGasStationNamesService, _dio);
  }

  /// Fetches the instant feed, then indexes it for searching and averages it.
  Future<Map<int, GasStation>> getCurrentPrices() async {
    final Map<int, GasStation> gasStationPrices = await _getGasStationPricesService.getCurrentPrices();
    setGasStations(gasStationPrices);
    return gasStationPrices;
  }

  /// Reuses an already fetched set of stations, e.g. one restored from cache.
  void setGasStations(final Map<int, GasStation> stations) {
    _searchGasStationService.setGasStations(stations);
    _priceStatisticsService.computeGlobalStatistics(stations);
  }

  GasStation findBestGasStation(
    final Map<int, GasStation> gasStationPrices,
    final SearchGasStation search,
  ) {
    setGasStations(gasStationPrices);
    return _searchGasStationService.findCheapestInRange(search);
  }

  /// Every station matching [search], cheapest first.
  List<GasStation> findGasStations(
    final Map<int, GasStation> gasStationPrices,
    final SearchGasStation search,
  ) {
    setGasStations(gasStationPrices);
    return _searchGasStationService.findInRange(search);
  }

  /// Distance in meters between [id] and the last searched position.
  double distanceTo(final int id) => _searchGasStationService.distance(id);

  FuelPriceStatistics getPriceStatistics() => _priceStatisticsService.globalStatistics;

  void close() => _dio.close();
}

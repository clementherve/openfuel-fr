import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/model/fuel-price-statistics.model.dart';
import 'package:openfuelfr/src/service/get-gas-station-prices.service.dart';

export 'package:maps_toolkit/maps_toolkit.dart' show LatLng;

export 'src/constant/fuel_types.dart' show FuelType;
export 'src/model/fuel-price.model.dart' show FuelPrice;
export 'src/model/gas-station.model.dart' show GasStation;
export 'src/model/open-day.model.dart' show OpenDay;
export 'src/model/opening-hours.model.dart' show OpeningHours;
export 'src/model/search-gas-station.model.dart' show SearchGasStation;
export 'src/service/get-gas-station-names.service.dart';
export 'src/service/price-statistics.service.dart' show PriceStatisticsService;
export 'src/service/search-gas-stations.service.dart' show SearchGasStationService;

class OpenFuelService {
  late Dio _dio;
  late GetGasStationNamesService _getGasStationNamesService;
  late GetGasStationPricesService _getGasStationPricesService;
  late SearchGasStationService _searchGasStationService;
  late PriceStatisticsService _priceStatisticsService;

  OpenFuelService() {
    _dio = Dio();
    _getGasStationNamesService = GetGasStationNamesService(Dio());
    _getGasStationPricesService = GetGasStationPricesService(_getGasStationNamesService, _dio);
    _searchGasStationService = SearchGasStationService();
    _priceStatisticsService = PriceStatisticsService();
  }

  Future<Map<int, GasStation>> getCurrentPrices() async {
    var gasStationPrices = await _getGasStationPricesService.getCurrentPrices();
    _searchGasStationService.setGasStations(gasStationPrices);
    _priceStatisticsService.computeGlobalStatistics(gasStationPrices);
    return gasStationPrices;
  }

  GasStation findBestGasStation(gasStationsPrices, searchGasSationDto) {
    _searchGasStationService.setGasStations(gasStationsPrices);
    return _searchGasStationService.findCheapestInRange(searchGasSationDto);
  }

  FuelPriceStatistics getPriceStatistics() {
    return _priceStatisticsService.globalStatistics;
  }
}

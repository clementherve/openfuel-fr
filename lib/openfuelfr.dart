import 'package:dio/dio.dart';
import 'package:openfuelfr/src/service/gas_station_name_service.dart';
import 'package:openfuelfr/src/service/openfuelfr_service.dart';
import 'package:openfuelfr/src/service/price_statistics_service.dart';

export 'src/service/gas_station_name_service.dart';

export 'src/service/price_statistics_service.dart' show PriceStatisticsService;
export 'src/service/search_gas_stations.dart' show SearchGasStation;

export 'src/model/fuel.dart' show Fuel;
export 'src/model/opening_day.dart' show OpenDay;
export 'src/model/opening_hours.dart' show OpeningHours;
export 'src/model/gas_station.dart' show GasStation;

export 'src/constant/fuel_types.dart' show FuelType;

export 'package:maps_toolkit/maps_toolkit.dart' show LatLng;

class OpenFuelService extends OpenFuelFrService {
  OpenFuelService() : super(GasStationNameService(Dio()), PriceStatisticsService(), Dio());
}

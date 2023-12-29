import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/service/gas_station_name_service.dart';
import 'package:openfuelfr/src/service/price_statistics_service.dart';

void main(List<String> args) async {
  final dio = Dio();
  final OpenFuelFrService openFuelFR = OpenFuelFrService(GasStationNameService(dio), PriceStatisticsService(), dio);
  final Map<int, GasStation> gasStations = await openFuelFR.fetchInstantPrices();
  final SearchGasStation search = SearchGasStation.station(gasStations);

  final GasStation cheapest = search.findCheapestInRange(LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false, fuelType: FuelType.e10, lastUpdated: Duration(hours: 5), searchRadius: 10000);

  print('name: ${cheapest.name}');
  for (var fuel in cheapest.fuels) {
    print('\t${fuel.type}: ${fuel.price}');
  }
}

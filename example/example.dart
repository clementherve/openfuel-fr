import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelService openFuelService = OpenFuelService();

  final Map<int, GasStation> stations = await openFuelService.getCurrentPrices();

  final SearchGasStation query = SearchGasStation(
    location: LatLng(45.75892691993614, 4.8614875724645525),
    searchRadiusMeters: 10000,
    lastUpdatedDays: const Duration(hours: 5),
    alwaysOpen: false,
    fuelType: FuelType.e10,
  );

  final GasStation cheapest = openFuelService.findBestGasStation(stations, query);

  print('${cheapest.displayName} - ${cheapest.address}, ${cheapest.city}');
  print('${(openFuelService.distanceTo(cheapest.id) / 1000).toStringAsFixed(1)}km away');
  for (final fuel in cheapest.fuelPrices) {
    print('\t${fuel.type}: ${fuel.price}');
  }

  print('\nnational average E10: ${openFuelService.getPriceStatistics().e10.toStringAsFixed(3)}');

  openFuelService.close();
}

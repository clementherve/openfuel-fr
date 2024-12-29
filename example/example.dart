import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelService openFuelService = OpenFuelService();

  final GasStation cheapest = openFuelService.findBestGasStation(
    openFuelService.getCurrentPrices(),
    SearchGasStation(
      location: LatLng(45.75892691993614, 4.8614875724645525),
      searchRadiusMeters: 10000,
      lastUpdatedDays: Duration(hours: 5),
      alwaysOpen: false,
      fuelType: FuelType.e10,
    ),
  );

  print('name: ${cheapest.name}');
  for (var fuel in cheapest.fuelPrices) {
    print('\t${fuel.type}: ${fuel.price}');
  }
}

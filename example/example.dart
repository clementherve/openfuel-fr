import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final Map<int, GasStation> gasStations = await openFuelFR.getInstantPrices();
  final SearchGasStation search = SearchGasStation.station(gasStations);

  final GasStation cheapest = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000);

  print('name: ${cheapest.name}');
  for (var fuel in cheapest.fuels) {
    print('\t${fuel.type}: ${fuel.price}');
  }
}

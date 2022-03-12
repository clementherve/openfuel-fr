import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<GasStation> gasStations = await openFuelFR.getInstantPrices();
  final SearchGasStation search = SearchGasStation(gasStations);

  GasStation? cheapest = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000);
  if (cheapest != null) {
    final String name = await openFuelFR.getGasStationName(cheapest.id);
    print(name);
    cheapest.fuels.forEach((fuel) => print('\t${fuel.type}: ${fuel.price}'));
  } else {
    print('Could not find any gas station');
  }
}

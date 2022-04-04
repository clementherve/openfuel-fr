import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/model/search_result.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<GasStation> gasStations = await openFuelFR.getInstantPrices();
  final SearchGasStation search = SearchGasStation(gasStations);

  SearchResult cheapest = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000);
  final String name = await openFuelFR.getGasStationName(cheapest.id);
  print(name);
  for (var fuel in cheapest.fuels) {
    print('\t${fuel.type}: ${fuel.price}');
  }
}

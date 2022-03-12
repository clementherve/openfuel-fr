import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<GasStation> sellingPoints = await openFuelFR.getInstantPrices();
  final SellingPointSearch search = SellingPointSearch(sellingPoints);

  GasStation? cheapestSP = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000);
  if (cheapestSP != null) {
    final String name = await openFuelFR.getGasStationName(cheapestSP.id);
    print(name);
    print(cheapestSP.toJson());
  } else {
    print('could not find any');
  }
}

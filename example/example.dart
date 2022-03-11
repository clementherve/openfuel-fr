import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<SellingPoint> sellingPoints = await openFuelFR.getInstantPrices();
  final SellingPointSearch search = SellingPointSearch(sellingPoints);

  SellingPoint? cheapestSP = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000);
  if (cheapestSP != null) {
    print(cheapestSP.toJson());
  } else {
    print('could not find any');
  }
}

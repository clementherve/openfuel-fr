import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<SellingPoint> sellingPoints = await openFuelFR.getInstantPrices();
  final SellingPointSearch search = SellingPointSearch(sellingPoints);

  search.search('Lyon', alwaysOpen: true).forEach((sp) {
    print('${sp.address} in ${sp.town} (always open: ${sp.isAlwaysOpen})');
    print('E10: ${sp.getFuelPriceByType(FuelType.e10)}');
  });
}

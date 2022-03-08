import 'package:openfuelfr/openfuelfr.dart';

void main(List<String> args) async {
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<SellingPoint> sellingPoints = await openFuelFR.getInstantPrices();

  SellingPointSearch.search('Lyon', sellingPoints,
          town: 'Lyon', alwaysOpen: true)
      .forEach((sp) {
    print('${sp.address} in ${sp.town} (always open: ${sp.isAlwaysOpen})');
    sp.pricedFuel.forEach((gas) {
      print('\t${gas.name} - ${gas.price}');
    });

    sp.openingDays.forEach((day) {
      print('\t${day.day} - isOpen: ${day.isOpen}');
      print(
          '\t\t${day.openingHours.openingHours} to ${day.openingHours.closingHour}');
    });
  });
}

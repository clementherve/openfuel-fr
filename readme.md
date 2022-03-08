# OpenFuel-Fr

Based on the data made public (here)[https://www.prix-carburants.gouv.fr/rubrique/opendata/], I have decided to build a Dart wrapper around it.

## Example

```dart
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<SellingPoint> sellingPoints = await openFuelFR.getInstantPrices();

  SellingPointSearch.search('Lyon', sellingPoints).forEach((sp) {
    print('${sp.address}');
    sp.pricedFuel.forEach((gas) {
      print('\t${gas.name} - ${gas.price}');
    });
  });
```

## ToDo
- Add more requests (daily, yearly, archive)
- Add more tests (search test...)
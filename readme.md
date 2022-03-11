# OpenFuel-Fr

Based on the data made public [here](https://www.prix-carburants.gouv.fr/rubrique/opendata/), I have decided to build a Dart wrapper around it.

## Example

```dart
  final SellingPointSearch search = SellingPointSearch(sellingPoints);

  SellingPoint? cheapestSP = search.findCheapestInRange(
      LatLng(45.75892691993614, 4.8614875724645525),
      alwaysOpen: false,
      fuelType: FuelType.e10,
      lastUpdated: Duration(hours: 5),
      searchRadius: 10000
  );

  if (cheapestSP == null) {
    // handle gracefully
  }
  print(cheapestSP.toJson());
```

## ToDo
- Add more requests (daily, yearly, archive)
- Add more tests (search test...)
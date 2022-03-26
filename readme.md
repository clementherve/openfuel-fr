# OpenFuel-Fr

Based on the data made public [here](https://www.prix-carburants.gouv.fr/rubrique/opendata/), I have decided to build a Dart wrapper around it.

## Example

```dart
  // get prices and parse them
  final OpenFuelFR openFuelFR = OpenFuelFR();
  final List<GasStation> gasStations = await openFuelFR.getInstantPrices();

  // other search types are available
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
```

## To-Do
- Add more requests (daily, yearly, archive)
- Mock data for tests
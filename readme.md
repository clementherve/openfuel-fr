# OpenFuel-Fr

Un client Dart pour récupérer les prix des carburants en France, depuis les données gouvernementales ouvertes disponibles [ici](https://www.prix-carburants.gouv.fr/rubrique/opendata/).

## Principales données récupérées
**GasStation**
```dart
  int id;
  LatLng position;
  String address;
  String town;
  bool isAlwaysOpen;
  List<OpeningDay> OpeningDay;
  List<Fuel> fuelPrices;
```

**Fuel**
```dart
  String fuelType;
  DateTime lastUpdated;
  double price;
```


## Example

```dart
  // get prices and parse them
  final dio = Dio();
  final OpenFuelFrService openFuelFR = OpenFuelFrService(GasStationNameService(dio), PriceStatisticsService(), dio);
  final List<GasStation> gasStations = await openFuelFR.fetchInstantPrices();

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
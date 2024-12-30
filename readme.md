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
  final OpenFuelService openFuelService = OpenFuelService();

  final GasStation cheapest = openFuelService.findBestGasStation(
    openFuelService.getCurrentPrices(),
    SearchGasStation(
      location: LatLng(45.75892691993614, 4.8614875724645525),
      searchRadiusMeters: 10000,
      lastUpdatedDays: Duration(hours: 5),
      alwaysOpen: false,
      fuelType: FuelType.e10,
    ),
  );

  print('name: ${cheapest.name}');
  for (var fuel in cheapest.fuelPrices) {
    print('\t${fuel.type}: ${fuel.price}');
  }
```
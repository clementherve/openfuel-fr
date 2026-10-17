# OpenFuel-Fr

Un client Dart pour récupérer les prix des carburants en France, depuis les données
gouvernementales ouvertes disponibles [ici](https://www.prix-carburants.gouv.fr/rubrique/opendata/).

Le flux instantané est servi en ZIP/XML (ISO-8859-1) et ne contient pas le nom des
enseignes : celles-ci sont complétées depuis une liste annexe indexée par identifiant
de station. Une station inconnue de cette liste garde sa ville comme libellé.

## Installation

```yaml
dependencies:
  openfuelfr:
    git: https://github.com/clementherve/openfuel-fr
```

## Modèle

**GasStation**

```dart
int id;
String name;          // enseigne, ou '-' si inconnue
String brand;
LatLng position;
String address;
String city;
String postalCode;
bool isAlwaysOpen;
List<String> services;
List<OpenDay> openDays;
List<FuelPrice> fuelPrices;

String get displayName; // name, à défaut brand, à défaut la ville
bool get hasPosition;
bool sells(String fuelType);
FuelPrice? getFuelByType(String fuelType);
double getFuelPriceByType(String fuelType, {double elseValue = double.infinity});
```

**FuelPrice**

```dart
String type;
DateTime lastUpdated;
double price;     // double.infinity si le prix est inconnu
bool get isKnown;
bool get isFresh; // moins de 2 jours
```

## Exemple

```dart
final OpenFuelService openFuelService = OpenFuelService();

final Map<int, GasStation> stations = await openFuelService.getCurrentPrices();

final SearchGasStation query = SearchGasStation(
  location: LatLng(45.75892691993614, 4.8614875724645525),
  searchRadiusMeters: 10000,
  lastUpdatedDays: const Duration(hours: 5),
  alwaysOpen: false,
  fuelType: FuelType.e10,
);

// la station la moins chère du rayon
final GasStation cheapest = openFuelService.findBestGasStation(stations, query);

// toutes les stations du rayon, de la moins chère à la plus chère
final List<GasStation> all = openFuelService.findGasStations(stations, query);

// distance en mètres depuis la dernière recherche
final double meters = openFuelService.distanceTo(cheapest.id);

// moyennes nationales par carburant
final FuelPriceStatistics stats = openFuelService.getPriceStatistics();
```

## Cache et isolate

Le flux zippé pèse ~1 Mo mais se décode en plusieurs dizaines de Mo d'objets, et
le téléchargement prend une vingtaine de secondes. Pour mettre en cache et
décoder hors du thread principal, téléchargement et décodage sont séparés :

```dart
final List<int> zipped = await openFuelService.downloadInstantFeed();
final GasStationNames names = await openFuelService.downloadNames();
// ... écrire `zipped` sur disque ...

// `parseInstantFeed` est pure : pas d'IO, pas d'état
final Map<int, GasStation> stations = await Isolate.run(
  () => OpenFuelService.parseInstantFeed(zipped, names: names),
);
openFuelService.setGasStations(stations);
```

`findBestGasStation` est tolérant : si aucune station ne satisfait tous les critères,
les filtres optionnels (favoris, 24/24) sont relâchés, et si le rayon est vide la
station la plus proche est renvoyée. `findGasStations` est strict et renvoie une liste
vide si rien ne correspond.

## Tests

```sh
dart test              # tests unitaires, hors ligne
dart test test/network # tests qui interrogent le vrai flux
```

import 'package:openfuelfr/openfuelfr.dart';

class SearchResult extends GasStation {
  late double distance = 0;
  late String name = 'n/a';

  SearchResult(final GasStation gs)
      : super(
          gs.id,
          gs.position,
          gs.address,
          gs.town,
          gs.isAlwaysOpen,
          gs.openingDays,
          gs.fuels,
        );

  @override
  Map toJson() {
    return {
      'id': id,
      'position': [
        position.latitude,
        position.longitude,
      ],
      'distance': distance,
      'name': name,
      'address': address,
      'town': town,
      'is_always_open': isAlwaysOpen,
      'prices': [fuels.map((e) => e.toJson())],
      'opening_days': [openingDays.map((e) => e.toJson())]
    };
  }
}

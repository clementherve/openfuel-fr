import 'dart:convert';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/model/fuel_price_statistics.dart';
import 'package:openfuelfr/src/utils/xmlparser.dart';
import 'package:requests/requests.dart';
import 'package:xml/xml.dart';
import 'utils/archiveparser.dart';
import 'package:meta/meta.dart';

class OpenFuelFR {
  late Map<String, dynamic> _names = {};
  late FuelPriceStatistics _statistics = FuelPriceStatistics.zero();

  OpenFuelFR({Map<String, dynamic>? names}) {
    _names = names ?? {};
  }

  /// return the names of all gas stations, indexe by their id
  @visibleForTesting
  Future<Map<String, dynamic>> getGasStationNames() async {
    var response = await Requests.get(Endpoints.names);
    if (response.statusCode >= 400) return {};
    return jsonDecode(response.body);
  }

  String _getName(final int id) {
    return _names[id.toString()]?['marque'] ?? '-';
  }

  void computeStatistics(final List<GasStation> stations) {
    _statistics = stations.fold<FuelPriceStatistics>(FuelPriceStatistics.zero(),
        (prev, station) {
      return FuelPriceStatistics(
        e10: prev.e10 + station.getFuelPriceByType(FuelType.e10, elseValue: 0),
        gazole: prev.gazole +
            station.getFuelPriceByType(FuelType.gazole, elseValue: 0),
        sp95:
            prev.sp95 + station.getFuelPriceByType(FuelType.sp95, elseValue: 0),
        sp98:
            prev.sp98 + station.getFuelPriceByType(FuelType.sp98, elseValue: 0),
        gplc:
            prev.gplc + station.getFuelPriceByType(FuelType.gplc, elseValue: 0),
        e85: prev.e85 + station.getFuelPriceByType(FuelType.e85, elseValue: 0),
      );
    });
  }

  /// return a list of selling points with instant prices
  Future<Map<int, GasStation>> getInstantPrices() async {
    // if no names were provided, we fetch them
    if (_names.isEmpty) _names = await getGasStationNames();

    // then we fetch the prices
    var response = await Requests.get(Endpoints.instant);

    if ((response.statusCode ?? 400) >= 400) return {};

    final XmlDocument xml = await ArchiveParser.toXML(response.bodyBytes);
    if (xml.children.length < 3) return {};

    final Map<int, GasStation> stations = xml.children[2].children
        .map((xml) => XmlParser.toGasStation(xml))
        .where((station) => station.fuels.isNotEmpty && station.address != '-')
        .fold<Map<int, GasStation>>({}, (value, element) {
      return {
        ...value,
        element.id: element..name = _getName(element.id),
      };
    });

    computeStatistics(stations.values.toList());

    return stations;
  }

  /// return a list of selling points with daily prices
  Future<List<GasStation>> getDailyPrices() async {
    throw Exception('not implemented');
  }

  FuelPriceStatistics get getStatistics => _statistics;
}

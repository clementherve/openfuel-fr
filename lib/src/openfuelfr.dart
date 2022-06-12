import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/utils/xmlparser.dart';
import 'package:xml/xml.dart';

import 'utils/archiveparser.dart';

class OpenFuelFR {
  late Dio _dio;
  late Map<String, dynamic> _names = {};

  OpenFuelFR({Map<String, dynamic>? names}) {
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 30, followRedirects: true));
    _names = names ?? {};
  }

  /// return the names of all gas stations, indexe by their id
  Future<Map<String, dynamic>> getGasStationNames() async {
    final Response response = await _dio.get(Endpoints.names);
    if ((response.statusCode ?? 400) >= 400) return {};
    return jsonDecode(response.data);
  }

  String _getName(final int id) {
    return _names[id.toString()]?['marque'] ?? '-';
  }

  /// return a list of selling points with instant prices
  Future<Map<int, GasStation>> getInstantPrices() async {
    // if no names were provided, we fetch them
    if (_names.isEmpty) _names = await getGasStationNames();

    // then we fetch the prices
    final Response response = await _dio.get(Endpoints.instant,
        options: Options(responseType: ResponseType.bytes));

    if ((response.statusCode ?? 400) >= 400) return {};

    final XmlDocument xml = await ArchiveParser.toXML(response.data);
    if (xml.children.length < 3) return {};

    return xml.children[2].children
        .map((xml) => XmlParser.toGasStation(xml))
        .where((station) => station.fuels.isNotEmpty && station.address != '-')
        .fold<Map<int, GasStation>>({}, (value, element) {
      return {
        ...value,
        element.id: element..name = _getName(element.id),
      };
    });
  }

  /// return a list of selling points with daily prices
  Future<List<GasStation>> getDailyPrices() async {
    throw Exception('not implemented');
  }
}

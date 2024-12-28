import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/exception/http.exception.dart';

class GetGasStationNamesService {
  final Dio _dio;
  late Map<String, dynamic> _names = {};

  GetGasStationNamesService(this._dio, {Map<String, dynamic>? names}) {
    _names = names ?? {};
  }

  Map<String, dynamic> get names => _names;

  String getNameById(final int stationId) {
    return _names[stationId.toString()]?['marque'] ?? '-';
  }

  // return the names of all gas stations, indexe by their id
  Future<Map<String, dynamic>> getNames() async {
    var response = await _dio.get(Endpoints.names);

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    _names = jsonDecode(response.data);
    return _names;
  }
}

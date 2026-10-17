import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';

class GetGasStationNamesService {
  final Dio _dio;
  GasStationNames _names;

  GetGasStationNamesService(this._dio, {GasStationNames? names}) : _names = names ?? const GasStationNames.empty();

  GasStationNames get names => _names;

  String getBrandById(final int stationId) => _names.brandOf(stationId);

  String getNameById(final int stationId) => _names.nameOf(stationId);

  /// return the names of all gas stations, indexed by their id
  Future<GasStationNames> getNames() async {
    final Response<dynamic> response = await _dio.get<dynamic>(Endpoints.names);

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    final dynamic data = response.data;
    // dio decodes json itself when the server announces it, the gist does not
    _names = GasStationNames(
      data is String ? Map<String, dynamic>.from(jsonDecode(data) as Map) : Map<String, dynamic>.from(data as Map),
    );
    return _names;
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/exception/http.exception.dart';

/// The opendata feed carries no brand, so names come from a side list keyed
/// by station id. Stations missing from it keep their fallback label.
class GetGasStationNamesService {
  final Dio _dio;
  Map<String, dynamic> _names;

  GetGasStationNamesService(this._dio, {Map<String, dynamic>? names}) : _names = names ?? {};

  Map<String, dynamic> get names => _names;

  Map<String, dynamic>? _entry(final int stationId) {
    final dynamic entry = _names[stationId.toString()];
    return entry is Map ? Map<String, dynamic>.from(entry) : null;
  }

  String getBrandById(final int stationId) => _entry(stationId)?['marque'] as String? ?? '-';

  String getNameById(final int stationId) {
    final Map<String, dynamic>? entry = _entry(stationId);
    return entry?['nom'] as String? ?? entry?['marque'] as String? ?? '-';
  }

  /// return the names of all gas stations, indexed by their id
  Future<Map<String, dynamic>> getNames() async {
    final Response<dynamic> response = await _dio.get<dynamic>(Endpoints.names);

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    final dynamic data = response.data;
    // dio decodes json itself when the server announces it, the gist does not
    _names =
        data is String ? Map<String, dynamic>.from(jsonDecode(data) as Map) : Map<String, dynamic>.from(data as Map);
    return _names;
  }
}

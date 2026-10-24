import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';

class GetGasStationNamesService {
  final Dio _dio;
  GasStationNames _names;

  GetGasStationNamesService(this._dio, {GasStationNames? names}) : _names = names ?? const GasStationNames.empty();

  GasStationNames get names => _names;

  String getNameById(final int stationId) => _names.nameOf(stationId);

  /// return the names of all gas stations, indexed by their id
  Future<GasStationNames> getNames() async {
    final Response<dynamic> response = await _dio.get<dynamic>(Endpoints.names);

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    // dio decodes json itself when the server announces it
    final dynamic payload = response.data;
    final dynamic data = payload is String ? jsonDecode(payload) : payload;

    if (data is! List) {
      throw FormatException('Expected a JSON list, got ${data.runtimeType}');
    }

    // rows without a usable numeric id or a non-empty string name are skipped
    // rather than aborting the whole list
    final Map<int, String> parsed = <int, String>{};
    for (final dynamic item in data) {
      if (item is! Map) {
        continue;
      }
      final int? id = int.tryParse('${item['id_station_officiel']}');
      final dynamic name = item['nom_normalise'];
      if (id != null && name is String && name.isNotEmpty) {
        parsed[id] = name;
      }
    }

    _names = GasStationNames(parsed);
    return _names;
  }
}

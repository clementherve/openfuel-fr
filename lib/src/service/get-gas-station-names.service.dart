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
    // dio decodes json itself when the server announces it
    final List<dynamic> rows = (data is String ? jsonDecode(data) : data) as List<dynamic>;

    _names = GasStationNames({
      for (final dynamic row in rows)
        if (row is Map && row['id_station_officiel'] != null && row['nom_normalise'] is String)
          row['id_station_officiel'].toString(): <String, dynamic>{
            // the dataset only carries a normalised brand; `nameOf` falls back
            // to `marque`, so it doubles as the station's label
            'marque': row['nom_normalise'] as String,
          },
    });
    return _names;
  }
}

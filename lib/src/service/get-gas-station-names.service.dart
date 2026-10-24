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

    final dynamic data = response.data;
    if (data is! List) {
      throw UnsupportedError(
        "Réponse inattendue : une liste JSON était attendue, reçu ${data.runtimeType}",
      );
    }

    _names = GasStationNames({
      for (final item in data.cast<Map<String, dynamic>>())
        if (item["id_station_officiel"] != null && item["nom_normalise"] != null)
          int.parse(item["id_station_officiel"].toString()): item["nom_normalise"].toString(),
    });
    return _names;
  }
}

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';

import 'package:openfuelfr/src/utils/archive_utils.dart';
import 'package:xml/xml.dart';

class GetGasStationPricesService {
  final GetGasStationNamesService _gasStationNameService;
  final Dio _dio;
  Map<int, GasStation> _currentPrices = {};

  Map<int, GasStation> get currentPrices => _currentPrices;

  GetGasStationPricesService(this._gasStationNameService, this._dio);

  /// return a map of selling points with instant prices, keyed by station id
  Future<Map<int, GasStation>> getCurrentPrices() async {
    // if no names were provided, we fetch them. A failure here is not fatal:
    // stations simply fall back to their town as a label.
    if (_gasStationNameService.names.isEmpty) {
      try {
        await _gasStationNameService.getNames();
      } on Exception {
        // names are cosmetic, prices are not
      }
    }

    final Response<dynamic> response = await _dio.get<dynamic>(
      Endpoints.instant,
      options: Options(responseType: ResponseType.bytes),
    );

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    final XmlDocument xml = ArchiveUtils.toXML(response.data as List<int>);

    _currentPrices = {
      for (final station in xml
          .findAllElements('pdv')
          .map(GasStation.tryFromXml)
          .whereType<GasStation>()
          .where((station) => station.fuelPrices.isNotEmpty && station.hasPosition))
        station.id: station
          ..name = _gasStationNameService.getNameById(station.id)
          ..brand = _gasStationNameService.getBrandById(station.id),
    };

    return _currentPrices;
  }
}

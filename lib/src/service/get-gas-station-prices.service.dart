import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/exception/http.exception.dart';
import 'package:openfuelfr/src/utils/archive_utils.dart';
import 'package:xml/xml.dart';

class GetGasStationPricesService {
  final GetGasStationNamesService _gasStationNameService;
  final Dio _dio;
  late Map<int, GasStation> _currentPrices = {};

  Map<int, GasStation> get currentPrices => _currentPrices;

  GetGasStationPricesService(this._gasStationNameService, this._dio);

  /// return a list of selling points with instant prices
  Future<Map<int, GasStation>> getCurrentPrices() async {
    // if no names were provided, we fetch them
    if (_gasStationNameService.names.isEmpty) {
      await _gasStationNameService.getNames();
    }

    // then we fetch the prices
    var response = await _dio.get(Endpoints.instant, options: Options(responseType: ResponseType.bytes));

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    final XmlDocument xml = await ArchiveUtils.toXML(response.data);
    if (xml.children.length < 3) {
      return {};
    }

    _currentPrices = xml.children[2].children
        .map((xml) => GasStation.fromXML(xml))
        .where((station) => station.fuelPrices.isNotEmpty && station.address != '-')
        .fold<Map<int, GasStation>>({}, (value, element) {
      return {
        ...value,
        element.id: element..name = _gasStationNameService.getNameById(element.id),
      };
    });

    return _currentPrices;
  }
}

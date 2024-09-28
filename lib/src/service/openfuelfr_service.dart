import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/model/fuel_price_statistics.dart';
import 'package:openfuelfr/src/utils/archive_utils.dart';
import 'package:xml/xml.dart';

class OpenFuelFrService {
  final GasStationNameService _gasStationNameService;
  final PriceStatisticsService _priceStatisticsService;
  final Dio _dio;
  late Map<int, GasStation> _currentPrices = {};

  FuelPriceStatistics get statistics => _priceStatisticsService.globalStatistics;
  Map<int, GasStation> get currentPrices => _currentPrices;

  OpenFuelFrService(this._gasStationNameService, this._priceStatisticsService, this._dio);

  /// return a list of selling points with instant prices
  Future<Map<int, GasStation>> getCurrentPrices() async {
    // if no names were provided, we fetch them
    if (_gasStationNameService.names.isEmpty) {
      await _gasStationNameService.getNames();
    }

    // then we fetch the prices
    var response = await _dio.get(Endpoints.instant, options: Options(responseType: ResponseType.bytes));

    if ((response.statusCode ?? 400) >= 400) {
      return {};
    }

    final XmlDocument xml = await ArchiveUtils.toXML(response.data);
    if (xml.children.length < 3) {
      return {};
    }

    _currentPrices = xml.children[2].children
        .map((xml) => GasStation.fromXML(xml))
        .where((station) => station.fuels.isNotEmpty && station.address != '-')
        .fold<Map<int, GasStation>>({}, (value, element) {
      return {
        ...value,
        element.id: element..name = _gasStationNameService.getNameById(element.id),
      };
    });

    _priceStatisticsService.computeGlobalStatistics(_currentPrices.values.toList());

    return _currentPrices;
  }
}

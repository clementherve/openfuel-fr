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

  /// Downloads the instant feed, still zipped.
  ///
  /// Kept separate from parsing so callers can cache the bytes, which are two
  /// orders of magnitude smaller than the stations they decode to, and run the
  /// parse off the main isolate.
  Future<List<int>> downloadInstantFeed() async {
    final Response<List<int>> response = await _dio.get<List<int>>(
      Endpoints.instant,
      options: Options(responseType: ResponseType.bytes),
    );

    if ((response.statusCode ?? 400) >= 400) {
      throw HttpException(response.statusMessage, response.statusCode);
    }

    return response.data ?? const [];
  }

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

    _currentPrices = parseInstantFeed(
      await downloadInstantFeed(),
      names: _gasStationNameService.names,
    );

    return _currentPrices;
  }

  /// Decodes a zipped instant feed into stations. Pure: no IO, no state, so it
  /// is safe to hand to `Isolate.run`.
  static Map<int, GasStation> parseInstantFeed(
    final List<int> zippedFeed, {
    final GasStationNames names = const GasStationNames.empty(),
  }) {
    final XmlDocument xml = ArchiveUtils.toXML(zippedFeed);

    return {
      for (final station in xml
          .findAllElements('pdv')
          .map(GasStation.tryFromXml)
          .whereType<GasStation>()
          .where((station) => station.fuelPrices.isNotEmpty && station.hasPosition))
        station.id: station..name = names.nameOf(station.id),
    };
  }
}

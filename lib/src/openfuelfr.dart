import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

class OpenFuelFR {
  late Dio _dio;
  final _logger = Logger('OpenFuelFR');

  OpenFuelFR() {
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 30, followRedirects: true));
    _logger.config(Level.ALL);

    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  // parse a xml to a selling point
  SellingPoint _toSellingPoint(final XmlNode xml) {
    final String address = xml.getElement('adresse')?.innerText ?? '-';
    final String town = xml.getElement('ville')?.innerText ?? '-';

    // see Q4 https://www.prix-carburants.gouv.fr/rubrique/opendata/
    final double lat =
        double.parse(xml.getAttribute('latitude') ?? '0.0') / 100000;
    final double lng =
        double.parse(xml.getAttribute('longitude') ?? '0.0') / 100000;

    final Iterable<XmlElement> pricesXML = xml.findAllElements('prix');

    final List<PricedFuel> pricedFuel = pricesXML.map((e) {
      final String name = e.getAttribute('nom') ?? '-';
      final DateTime lastUpdated =
          DateTime.parse(e.getAttribute('maj') ?? '19700101');
      final double price = double.parse(e.getAttribute('valeur') ?? '0.0');

      return PricedFuel(name, lastUpdated, price);
    }).toList();

    final bool alwaysOpened =
        xml.getElement('horaires')?.getAttribute('automate-24-24') == '1';

    final Iterable<XmlElement> openingDaysXML = xml.findAllElements('jour');
    final List<OpeningDays> openingDays = openingDaysXML.map((e) {
      final String name = e.getAttribute('nom') ?? '-';
      final bool isOpen = e.getAttribute('ferme') == '';

      final String openingHour =
          e.getElement('horaire')?.getAttribute('ouverture') ??
              (alwaysOpened ? '00.00' : '-');
      final String closingHour =
          e.getElement('horaire')?.getAttribute('fermeture') ??
              (alwaysOpened ? '23.59' : '-');

      final OpeningHours openingHours = OpeningHours(openingHour, closingHour);

      return OpeningDays(name, isOpen, openingHours);
    }).toList();

    return SellingPoint(
        LatLng(lat, lng), address, town, alwaysOpened, openingDays, pricedFuel);
  }

  // return a list of selling points with instant prices
  Future<List<SellingPoint>> getInstantPrices() async {
    final Stopwatch requestSW = Stopwatch()..start(); // debug
    final Response response = await _dio.get(Endpoints.instant,
        options: Options(responseType: ResponseType.bytes));
    _logger.info('request: ${requestSW.elapsed.inMilliseconds}ms'); // debug

    if ((response.statusCode ?? 400) >= 400) {
      return List.empty();
    }

    final Stopwatch createArchiveSW = Stopwatch()..start(); // debug

    final Archive archive = ZipDecoder().decodeBytes(response.data);
    _logger.info(
        'create the archive: ${createArchiveSW.elapsed.inMilliseconds}ms'); // debug

    if (archive.isEmpty) {
      return List.empty();
    }

    final Stopwatch unzipSW = Stopwatch()..start(); // debug
    final List<int> data = archive.first.content; // might be very slow
    _logger.info('unzip: ${unzipSW.elapsed.inMilliseconds}ms'); // debug

    final XmlDocument xml = XmlDocument.parse(String.fromCharCodes(data));
    if (xml.children.length < 2) {
      return List.empty();
    }

    return xml.children[2].children.map((e) => _toSellingPoint(e)).toList();
  }
}

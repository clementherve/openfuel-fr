import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:xml/xml.dart';

class OpenFuelFR {
  late Dio _dio;

  OpenFuelFR() {
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 30, followRedirects: true));
  }

  // parse a XmlNode to a SellingPoint
  GasStation _toSellingPoint(final XmlNode xml) {
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

    return GasStation(
        LatLng(lat, lng), address, town, alwaysOpened, openingDays, pricedFuel);
  }

  // return a list of selling points with instant prices
  Future<List<GasStation>> getInstantPrices() async {
    final Response response = await _dio.get(Endpoints.instant,
        options: Options(responseType: ResponseType.bytes));

    if ((response.statusCode ?? 400) >= 400) {
      return List<GasStation>.empty();
    }

    final Archive archive = ZipDecoder().decodeBytes(response.data);

    if (archive.isEmpty) {
      return List<GasStation>.empty();
    }

    final List<int> data = archive.first.content;

    final XmlDocument xml =
        XmlDocument.parse(String.fromCharCodes(data)); // beware: very slow!
    if (xml.children.length < 2) {
      return List<GasStation>.empty();
    }

    return xml.children[2].children.map((e) => _toSellingPoint(e)).toList();
  }
}

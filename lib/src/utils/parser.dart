import 'package:openfuelfr/openfuelfr.dart';
import 'package:xml/xml.dart';

import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;

class Parser {
  static GasStation toGasStation(final XmlNode xml) {
    final int id = int.parse(xml.getAttribute('id') ?? '0');

    final String address = xml.getElement('adresse')?.innerText ?? '-';
    final String town = xml.getElement('ville')?.innerText ?? '-';

    // see Q4 https://www.prix-carburants.gouv.fr/rubrique/opendata/
    final double lat =
        double.parse(xml.getAttribute('latitude') ?? '0.0') / 100000;
    final double lng =
        double.parse(xml.getAttribute('longitude') ?? '0.0') / 100000;

    final Iterable<XmlElement> pricesXML = xml.findAllElements('prix');

    final List<Fuel> pricedFuel = pricesXML.map((e) {
      final String name = e.getAttribute('nom') ?? '-';
      final DateTime lastUpdated =
          DateTime.parse(e.getAttribute('maj') ?? '19700101');
      double price = double.parse(e.getAttribute('valeur') ?? '0.0');

      if (price > 500) {
        // pas pour les flux instantanés...
        price = price / 1000; // 	Prix en euros multiplié par 1000
      }

      return Fuel(name, lastUpdated, price);
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

    return GasStation(id, LatLng(lat, lng), address, town, alwaysOpened,
        openingDays, pricedFuel);
  }

  static String toGasStationName(final String html) {
    dom.Document document = htmlparser.parse(html);
    dom.Element? e = document.querySelector('.colg p strong');
    return e == null ? 'n/a' : document.querySelector('.colg p strong')!.text;
  }
}

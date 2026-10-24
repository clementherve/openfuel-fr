import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/utils/archive_utils.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

/// Parses the ISO-8859-1 fixture the way the feed is actually served.
List<GasStation> _parseFixture() {
  final List<int> bytes = File('test/fixture/pdv_sample.xml').readAsBytesSync();
  final XmlDocument xml = XmlDocument.parse(latin1.decode(bytes));
  return xml.findAllElements('pdv').map(GasStation.tryFromXml).whereType<GasStation>().toList();
}

void main() {
  group('GasStation.tryFromXml', () {
    late List<GasStation> stations;

    setUp(() => stations = _parseFixture());

    test('parses every pdv node', () {
      expect(stations, hasLength(4));
    });

    test('scales coordinates down by 100000', () {
      final GasStation lyon = stations.firstWhere((s) => s.id == 69007001);
      expect(lyon.position.latitude, closeTo(45.75892, 0.00001));
      expect(lyon.position.longitude, closeTo(4.86148, 0.00001));
    });

    test('decodes latin-1 accents', () {
      expect(stations.firstWhere((s) => s.id == 75001003).city, equals('Montgenèvre'));
    });

    test('reads prices, postal code and services', () {
      final GasStation lyon = stations.firstWhere((s) => s.id == 69007001);
      expect(lyon.getFuelPriceByType(FuelType.gazole), equals(1.8));
      expect(lyon.getFuelPriceByType(FuelType.e10), equals(1.7));
      expect(lyon.postalCode, equals('69007'));
      expect(lyon.services, contains('Station de gonflage'));
    });

    test('reports a missing fuel instead of inventing a price', () {
      final GasStation paris = stations.firstWhere((s) => s.id == 75001003);
      expect(paris.sells(FuelType.gazole), isFalse);
      expect(paris.getFuelByType(FuelType.gazole), isNull);
      expect(paris.getFuelPriceByType(FuelType.gazole), equals(double.infinity));
      expect(paris.getFuelPriceByType(FuelType.gazole, elseValue: 0), equals(0));
    });

    test('reads opening days, ferme="1" meaning closed', () {
      final GasStation lyon = stations.firstWhere((s) => s.id == 69007001);
      final OpenDay monday = lyon.openDays.firstWhere((d) => d.day == 'Lundi');
      final OpenDay sunday = lyon.openDays.firstWhere((d) => d.day == 'Dimanche');

      expect(monday.isOpen, isTrue);
      expect(monday.openingHours.openingHour, equals('07.00'));
      expect(monday.openingHours.closingHour, equals('20.00'));
      expect(sunday.isOpen, isFalse);
      expect(lyon.isAlwaysOpen, isTrue);
      expect(stations.firstWhere((s) => s.id == 69008002).isAlwaysOpen, isFalse);
    });

    test('flags stations without coordinates', () {
      expect(stations.firstWhere((s) => s.id == 99999999).hasPosition, isFalse);
      expect(stations.firstWhere((s) => s.id == 69007001).hasPosition, isTrue);
    });

    test('falls back to the town when no name is known', () {
      expect(stations.firstWhere((s) => s.id == 69007001).displayName, equals('Lyon'));
    });

    test('ignores nodes that are not stations', () {
      final XmlDocument xml = XmlDocument.parse('<pdv_liste>\n  <pdv>text</pdv>\n</pdv_liste>');
      expect(GasStation.tryFromXml(xml.rootElement.children.first), isNull);
    });
  });

  group('ArchiveUtils', () {
    test('decodes a zipped latin-1 feed', () {
      final Archive archive = Archive()
        ..addFile(
          ArchiveFile.bytes(
            'PrixCarburants_instantane.xml',
            File('test/fixture/pdv_sample.xml').readAsBytesSync(),
          ),
        );

      final XmlDocument xml = ArchiveUtils.toXML(ZipEncoder().encode(archive));
      expect(xml.findAllElements('pdv'), hasLength(4));
    });

    test('returns an empty document for an archive with no xml', () {
      final Archive archive = Archive()..addFile(ArchiveFile.bytes('readme.txt', utf8.encode('nothing here')));
      expect(ArchiveUtils.toXML(ZipEncoder().encode(archive)).children, isEmpty);
    });
  });

  group('parseInstantFeed', () {
    List<int> zippedFixture() {
      final Archive archive = Archive()
        ..addFile(
          ArchiveFile.bytes(
            'PrixCarburants_instantane.xml',
            File('test/fixture/pdv_sample.xml').readAsBytesSync(),
          ),
        );
      return ZipEncoder().encode(archive);
    }

    test('keys usable stations by id and drops the unusable ones', () {
      final Map<int, GasStation> stations = OpenFuelService.parseInstantFeed(zippedFixture());

      // 99999999 has no coordinates and no prices at all
      expect(stations.keys, unorderedEquals([69007001, 69008002, 75001003]));
    });

    test('applies the name list when one is given', () {
      final Map<int, GasStation> stations = OpenFuelService.parseInstantFeed(
        zippedFixture(),
        names: const GasStationNames({
          69007001: 'Intermarché Jean Macé',
          69008002: 'Total',
        }),
      );

      expect(stations[69007001]!.name, equals('Intermarché Jean Macé'));
      // the list supplies the whole label, brand included
      expect(stations[69008002]!.name, equals('Total'));
      // absent from the list entirely
      expect(stations[75001003]!.name, equals('-'));
      expect(stations[75001003]!.displayName, equals('Montgenèvre'));
    });

    test('runs in an isolate', () async {
      final List<int> bytes = zippedFixture();
      final Map<int, GasStation> stations = await Isolate.run(() => OpenFuelService.parseInstantFeed(bytes));
      expect(stations, hasLength(3));
    });
  });

  group('serialization', () {
    test('a station survives a json round-trip', () {
      final GasStation original = _parseFixture().firstWhere((s) => s.id == 69007001)..name = 'Intermarché';
      final GasStation copy = GasStation.fromJson(jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);

      expect(copy.id, equals(original.id));
      expect(copy.name, equals('Intermarché'));
      expect(copy.city, equals(original.city));
      expect(copy.postalCode, equals(original.postalCode));
      expect(copy.services, equals(original.services));
      expect(copy.position.latitude, equals(original.position.latitude));
      expect(copy.isAlwaysOpen, equals(original.isAlwaysOpen));
      expect(copy.openDays.length, equals(original.openDays.length));
      expect(copy.getFuelPriceByType(FuelType.e10), equals(original.getFuelPriceByType(FuelType.e10)));
    });

    test('an unknown price encodes as null rather than crashing jsonEncode', () {
      final FuelPrice empty = FuelPrice.empty();
      expect(() => jsonEncode(empty.toJson()), returnsNormally);
      expect(FuelPrice.fromJson(jsonDecode(jsonEncode(empty.toJson())) as Map<String, dynamic>).isKnown, isFalse);
    });

    test('a search keeps a sub-day freshness window', () {
      final SearchGasStation search = SearchGasStation(
        location: LatLng(45.764, 4.840),
        searchRadiusMeters: 1000,
        fuelType: FuelType.e10,
        lastUpdatedDays: const Duration(hours: 5),
      );

      final SearchGasStation copy = SearchGasStation.fromJson(
        jsonDecode(jsonEncode(search.toJson())) as Map<String, dynamic>,
      );

      expect(copy.lastUpdatedDays, equals(const Duration(hours: 5)));
      expect(copy.location.latitude, equals(search.location.latitude));
      expect(copy.searchRadiusMeters, equals(search.searchRadiusMeters));
      expect(copy.fuelType, equals(search.fuelType));
    });
  });
}

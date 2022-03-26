import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/utils/parser.dart';
import 'package:test/test.dart';

void main() async {
  test('find_station_name.ok', () async {
    OpenFuelFR openFuel = OpenFuelFR();
    String gasStationName = await openFuel.getGasStationName(8360003);
    expect(gasStationName, equals('CARREFOUR CONTACT'));
  });

  test('', () async {
    OpenFuelFR openFuel = OpenFuelFR();
  });
}

import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  test('find_station_name.ok', () async {
    OpenFuelFR openFuel = OpenFuelFR();
    var foo = openFuel.getGasStationNames();
    print(foo);
    // String gasStationName = await openFuel.getGasStationName(8360003);
    // expect(gasStationName, equals('CARREFOUR CONTACT'));
  });

  test('', () async {
    OpenFuelFR openFuel = OpenFuelFR();
  });
}

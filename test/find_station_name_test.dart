import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  test('find_station_name', () async {
    OpenFuelFR openFuel = OpenFuelFR();
    var foo = await openFuel.getGasStationNames();
    expect(foo.entries.length, greaterThan(0));
    expect(foo['8360003']['nom'], equals('CARREFOUR CONTACT'));
  });
}

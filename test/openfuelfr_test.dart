import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  setUp(() {});

  test('connect.ok', () async {
    final OpenFuelFR openFuelFR = OpenFuelFR();
    final List<GasStation> gasStations = await openFuelFR.getInstantPrices();
    expect(gasStations.length, greaterThan(1));
  });
}

import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

void main() async {
  setUp(() {});

  test('connect.ok', () async {
    final OpenFuelFR openFuelFR = OpenFuelFR();
    final List<SellingPoint> sellingPoints =
        await openFuelFR.getInstantPrices();
    expect(sellingPoints.length, greaterThan(1));
  });
}

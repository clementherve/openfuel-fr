import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:test/test.dart';

/// Serves a canned body, so the name list can be tested without the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  test('maps the tabular dataset rows to station names', () async {
    final Dio dio = Dio()
      ..httpClientAdapter = _FakeAdapter(
        jsonEncode([
          {'id_station_officiel': 1000001, 'nom_normalise': 'Carrefour Market'},
          {'id_station_officiel': 1000002, 'nom_normalise': 'Carrefour'},
          // a row without an id or a name is ignored rather than keyed "null"
          {'id_station_officiel': null, 'nom_normalise': 'Sans id'},
          {'id_station_officiel': 1000003, 'nom_normalise': null},
        ]),
      );

    final GasStationNames names = await GetGasStationNamesService(dio).getNames();

    expect(names.brandOf(1000001), equals('Carrefour Market'));
    expect(names.nameOf(1000001), equals('Carrefour Market'));
    expect(names.brandOf(1000002), equals('Carrefour'));
    expect(names.nameOf(9999999), equals('-'));
    expect(names.asMap.keys, unorderedEquals(['1000001', '1000002']));
  });
}

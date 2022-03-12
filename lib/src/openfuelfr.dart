import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:openfuelfr/openfuelfr.dart';
import 'package:openfuelfr/src/constant/endpoints.dart';
import 'package:openfuelfr/src/utils/parser.dart';
import 'package:xml/xml.dart';

class OpenFuelFR {
  late Dio _dio;

  OpenFuelFR() {
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 30, followRedirects: true));
  }

  Future<String> getGasStationName(final int id) async {
    final Response response = await _dio.get('${Endpoints.name}$id',
        options: Options(
          headers: {
            "accept":
                "text/javascript, text/html, application/xml, text/xml, */*",
            "accept-language": "en-US,en;q=0.9",
            "sec-ch-ua":
                "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"98\", \"Google Chrome\";v=\"98\"",
            "sec-ch-ua-mobile": "?0",
            "sec-ch-ua-platform": "\"Linux\"",
            "sec-fetch-dest": "empty",
            "sec-fetch-mode": "cors",
            "sec-fetch-site": "same-origin",
            "x-prototype-version": "1.7",
            "x-requested-with": "XMLHttpRequest",
            "referrer": "https://www.prix-carburants.gouv.fr/",
            "referrerPolicy": "same-origin",
            "body": null,
            "method": "GET",
            "mode": "cors",
            "credentials": "include"
          },
        ));
    print(response.statusCode);
    print(response.statusMessage);
    if ((response.statusCode ?? 400) >= 400) {
      return '-';
    }

    return Parser.toGasStationName(response.data);
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

    return xml.children[2].children.map((e) => Parser.toGasStation(e)).toList();
  }

  Future<List<GasStation>> getDailyPrices() async {
    throw Exception('not implemented');
  }
}

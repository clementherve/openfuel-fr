import 'package:openfuelfr/src/model/selling_point.dart';

class SellingPointSearch {
  static List<SellingPoint> search(
      final String query, final List<SellingPoint> sellingPoints,
      {final String? town, final bool alwaysOpen = false}) {
    final String q = query.toLowerCase();
    return sellingPoints.where((sp) {
      return (sp.town.toLowerCase().contains(q) ||
              (sp.address.toLowerCase().contains(q) &&
                  sp.town.toLowerCase().contains(town ?? ''))) &&
          sp.openingDays.any((days) => days.isOpen) &&
          ((alwaysOpen == true) ? sp.isAlwaysOpen == alwaysOpen : true);
    }).toList();
  }
}

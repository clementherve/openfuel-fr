class FuelPriceStatistics {
  late double gazole;
  late double sp95;
  late double e10;
  late double sp98;
  late double gplc;
  late double e85;

  FuelPriceStatistics({
    required this.e10,
    required this.gazole,
    required this.sp95,
    required this.sp98,
    required this.gplc,
    required this.e85,
  });

  FuelPriceStatistics.zero() {
    gazole = 0.0;
    sp95 = 0.0;
    e10 = 0.0;
    sp98 = 0.0;
    gplc = 0.0;
    e85 = 0.0;
  }
}

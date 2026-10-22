class Endpoints {
  static const _base = 'https://donnees.roulez-eco.fr';
  static const instant = '$_base/opendata/instantane';
  static const daily = '$_base/opendata/jour';
  static const year = '$_base/opendata/annee';
  static String yearly(final int year) => '$_base/opendata/annee/$year';
  // the paginated `/data/` endpoint caps at 200 rows, so ask for the JSON
  // export: the same list of ~10k stations in a single request
  static const names = 'https://tabular-api.data.gouv.fr/api/resources/0207ded0-2d19-47af-b1a6-62915ec1b721/data/json/';
}

class Endpoints {
  static const _base = 'https://donnees.roulez-eco.fr';
  static const instant = '$_base/opendata/instantane';
  static const daily = '$_base/opendata/jour';
  static const year = '$_base/opendata/annee';
  static yearly(year) => '$_base/opendata/annee/$year';
  static const name =
      'https://www.prix-carburants.gouv.fr/map/recuperer_infos_pdv/';
}

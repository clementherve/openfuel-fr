class Endpoints {
  static const _base = 'https://donnees.roulez-eco.fr';
  static const instant = '$_base/opendata/instantane';
  static const daily = '$_base/opendata/jour';
  static const year = '$_base/opendata/annee';
  static yearly(year) => '$_base/opendata/annee/$year';
  static const names =
      'https://gist.githubusercontent.com/clementherve/bb8dbbf08036c58d233bac87da2a9ecc/raw/eb9fbca235ccaf23d7c6e44a762b05c7b8a9683b/stations.json';
}

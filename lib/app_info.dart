/// Dati fissi dell'app mostrati nella pagina Info e nella privacy policy.
abstract final class AppInfo {
  /// Deve coincidere con `version:` in pubspec.yaml (un test lo verifica).
  static const String version = '1.0.0';
  static const int buildNumber = 2;

  static const String developerName = 'Nicola De Nicolais';
  static const String developerEmail = 'ndn21dev@gmail.com';
  static const String developerWebsite = 'https://ndenicolais.github.io/';

  static const String privacyPolicyUrl =
      'https://ndenicolais.github.io/fivelink/privacy/';

  /// Data di "ultimo aggiornamento" della privacy policy, uguale a PRIVACY.md.
  static final DateTime privacyPolicyUpdatedAt = DateTime(2026, 10, 6);
}

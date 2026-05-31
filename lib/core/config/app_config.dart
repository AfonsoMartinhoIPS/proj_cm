/// Configuração global da aplicação baseada em variáveis de ambiente.
///
/// As constantes aqui definidas permitem alterar o comportamento da aplicação
/// sem modificar o código‑fonte, utilizando `--dart-define` durante a
/// compilação.  Se uma variável não for definida, assume o valor padrão
/// especificado.
class AppConfig {
  /// Se `true`, o Firestore utiliza o emulador local em vez da instância
  /// remota.
  ///
  /// Definir com:
  /// ```
  /// flutter run --dart-define=USE_EMULATOR=true
  /// ```
  static const bool useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  /// Se `true`, a fonte de dados Open Food Facts usa o ambiente de staging
  /// (world.openfoodfacts.**net**) em vez do ambiente de produção
  /// (world.openfoodfacts.**org**).
  ///
  /// Definir com:
  /// ```
  /// flutter run --dart-define=OPEN_FOOD_FACTS_USE_STAGING=true
  /// ```
  static const bool openFoodFactsUseStaging = bool.fromEnvironment(
      'OPEN_FOOD_FACTS_USE_STAGING',
      defaultValue: false);
}
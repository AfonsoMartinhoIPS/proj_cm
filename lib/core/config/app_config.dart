
class AppConfig {
  static const bool useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
    
  static const bool openFoodFactsUseStaging = bool.fromEnvironment('OPEN_FOOD_FACTS_USE_STAGING', defaultValue: false);
}
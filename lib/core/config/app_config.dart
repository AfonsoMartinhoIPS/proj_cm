
class AppConfig {
  static const bool useEmulator =
      bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
}
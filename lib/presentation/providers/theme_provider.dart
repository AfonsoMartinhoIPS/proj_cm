// lib/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier que persiste a preferência de tema do utilizador.
///
/// Armazena o valor da chave `theme_mode` nas `SharedPreferences` e expõe
/// o estado através de um [AsyncNotifier]. Se nenhum valor for encontrado,
/// assume [ThemeMode.system].
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'theme_mode';

  /// Constrói o estado inicial lendo o valor guardado nas preferências.
  ///
  /// Devolve [ThemeMode.system] se a chave não existir ou contiver um valor
  /// desconhecido.
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final mode = _fromString(raw);
    logger.d('ThemeMode: loaded $mode');
    return mode;
  }

  /// Altera o tema atual e persiste a escolha.
  ///
  /// Atualiza imediatamente o estado exposto e, em seguida, guarda o novo
  /// valor nas `SharedPreferences` para ser recuperado no próximo arranque.
  Future<void> setMode(ThemeMode mode) async {
    logger.d('ThemeMode: set $mode');
    state = AsyncValue.data(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  /// Converte uma string persistida no valor de [ThemeMode] correspondente.
  ///
  /// Valores reconhecidos: `'light'`, `'dark'`. Qualquer outro valor
  /// devolve [ThemeMode.system].
  ThemeMode _fromString(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

/// Provider que expõe o tema atual e permite a sua alteração.
///
/// Utilizado pelo `MaterialApp.router` para definir [ThemeMode] e por
/// widgets como o `SettingsScreen` para alternar entre os modos claro,
/// escuro e sistema.
final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
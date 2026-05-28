import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's preferred [ThemeMode] across app launches.
///
/// Storage: a single SharedPreferences string at [_prefsKey]. Values match
/// the names of the [ThemeMode] enum (`system` / `light` / `dark`). On first
/// launch (or unknown value) defaults to [ThemeMode.system] - matches the OS.
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  static const _prefsKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final mode = _fromString(raw);
    logger.d('ThemeMode: loaded $mode');
    return mode;
  }

  Future<void> setMode(ThemeMode mode) async {
    logger.d('ThemeMode: set $mode');
    state = AsyncValue.data(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  ThemeMode _fromString(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

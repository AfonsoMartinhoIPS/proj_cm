// lib/presentation/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/notifications/notification_coordinator.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';

/// Immutable snapshot of the user's daily-reminder preferences exposed by
/// [NotificationPrefsNotifier]. Lives in the provider so the settings UI
/// can render reactively without re-reading SharedPreferences every build.
class NotificationPrefs {
  final bool enabled;
  final TimeOfDay time;

  const NotificationPrefs({required this.enabled, required this.time});

  NotificationPrefs copyWith({bool? enabled, TimeOfDay? time}) =>
      NotificationPrefs(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

/// Settings-facing wrapper around [NotificationCoordinator]. The coordinator
/// owns Persisted SharedPreferences + scheduling; this notifier exposes a
/// read model + action methods that turn UI events into coordinator calls.
///
/// Reads `authProvider` + `nutritionLogsProvider` lazily on each action so
/// the scheduled message uses the latest data without re-watching them
/// reactively (which would force a reschedule on every meal log here too).
class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() async {
    final enabled = await NotificationCoordinator.isEnabled();
    final time = await NotificationCoordinator.getTime();
    return NotificationPrefs(enabled: enabled, time: time);
  }

  /// Toggle the daily reminder. Returns true on success; on permission
  /// denial the state stays disabled and the caller should surface a
  /// snackbar.
  Future<bool> setEnabled(bool enabled) async {
    final current = state.value;
    if (current == null) return false;
    if (enabled) {
      final (log, goals) = _todayContext();
      if (goals == null) {
        logger.w('NotificationPrefs: no goals on user, cannot enable');
        return false;
      }
      final ok = await NotificationCoordinator.enable(
        time: current.time,
        todayLog: log,
        goals: goals,
      );
      if (ok) state = AsyncValue.data(current.copyWith(enabled: true));
      return ok;
    } else {
      await NotificationCoordinator.disable();
      state = AsyncValue.data(current.copyWith(enabled: false));
      return true;
    }
  }

  Future<void> setTime(TimeOfDay time) async {
    final current = state.value;
    if (current == null) return;
    final (log, goals) = _todayContext();
    if (goals == null) return;
    await NotificationCoordinator.setTime(
      time: time,
      todayLog: log,
      goals: goals,
    );
    state = AsyncValue.data(current.copyWith(time: time));
  }

  /// (todayLog, goals) tuple snapshot for scheduling. Returns null goals
  /// when there's no logged-in user with goals, which the caller treats as
  /// "can't schedule, leave disabled".
  (NutritionLog?, NutritionGoals?) _todayContext() {
    final user = ref.read(authProvider).value;
    if (user == null) return (null, null);
    final logs = ref.read(nutritionLogsProvider).value ?? [];
    final today = todayKey();
    final log = logs.where((l) => l.date == today).firstOrNull;
    return (log, user.nutritionGoals);
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

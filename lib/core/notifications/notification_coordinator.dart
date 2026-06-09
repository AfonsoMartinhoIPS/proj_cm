// lib/core/notifications/notification_coordinator.dart

import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/notifications/notification_service.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bridges app data (nutrition log + goals + user prefs) to
/// [NotificationService]. Owns the SharedPreferences keys for the daily
/// reminder feature and computes the "objetivo cumprido" message body.
///
/// Two responsibilities:
///   1. Persist user prefs (enabled flag + chosen hour/minute).
///   2. Re-schedule the daily reminder with fresh content whenever the
///      nutrition log mutates (called from `NutritionLogsNotifier`).
///
/// Static API; no Riverpod plumbing needed by callers.
class NotificationCoordinator {
  NotificationCoordinator._();

  static const _prefEnabled = 'daily_notif_enabled';
  static const _prefHour = 'daily_notif_hour';
  static const _prefMinute = 'daily_notif_minute';

  /// Default fire time when the user enables notifications without picking
  /// one. 21:00 = end-of-day summary.
  static const TimeOfDay defaultTime = TimeOfDay(hour: 21, minute: 0);

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? false;
  }

  static Future<TimeOfDay> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getInt(_prefHour);
    final m = prefs.getInt(_prefMinute);
    if (h == null || m == null) return defaultTime;
    return TimeOfDay(hour: h, minute: m);
  }

  /// Enables the reminder: requests permission, persists the flag + time,
  /// then schedules with the current goal status. Returns false when the
  /// user denies the OS permission (state stays disabled).
  static Future<bool> enable({
    required TimeOfDay time,
    required NutritionLog? todayLog,
    required NutritionGoals goals,
  }) async {
    final granted = await NotificationService.requestPermission();
    if (!granted) {
      logger.w('NotificationCoordinator: permission denied');
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, true);
    await prefs.setInt(_prefHour, time.hour);
    await prefs.setInt(_prefMinute, time.minute);

    final content = _buildContent(todayLog: todayLog, goals: goals);
    await NotificationService.scheduleDailyReminder(
      time: time,
      title: content.title,
      body: content.body,
    );
    return true;
  }

  /// Disables the reminder: clears prefs + cancels every pending schedule.
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, false);
    await NotificationService.cancelAll();
  }

  /// Persist a new fire time without flipping the enabled flag. Reschedules
  /// only when notifications are already on; otherwise just stores the
  /// preference for when the user turns them on later.
  static Future<void> setTime({
    required TimeOfDay time,
    required NutritionLog? todayLog,
    required NutritionGoals goals,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, time.hour);
    await prefs.setInt(_prefMinute, time.minute);

    if (!await isEnabled()) return;
    final content = _buildContent(todayLog: todayLog, goals: goals);
    await NotificationService.scheduleDailyReminder(
      time: time,
      title: content.title,
      body: content.body,
    );
  }

  /// Re-arms the daily notification with fresh content reflecting the
  /// current day's totals. Called from `NutritionLogsNotifier` after every
  /// mutation so the message shown at fire time matches the latest log.
  ///
  /// No-op when the user hasn't enabled the reminder.
  static Future<void> reschedule({
    required NutritionLog? todayLog,
    required NutritionGoals goals,
  }) async {
    if (!await isEnabled()) return;
    final time = await getTime();
    final content = _buildContent(todayLog: todayLog, goals: goals);
    await NotificationService.scheduleDailyReminder(
      time: time,
      title: content.title,
      body: content.body,
    );
  }

  /// Renders the notification copy from today's totals vs goals.
  ///
  /// Tight on remaining-calorie wording: floors at 0 instead of negative
  /// so "Faltam -50 kcal" never appears. Always either "cumprido" or
  /// "quase lá" — never empty.
  static ({String title, String body}) _buildContent({
    required NutritionLog? todayLog,
    required NutritionGoals goals,
  }) {
    final consumed = todayLog?.totalCalories ?? 0;
    final goal = goals.calories;
    final met = consumed >= goal;

    if (met) {
      return (
        title: 'Objetivo cumprido',
        body: 'Atingiste as ${goal.toStringAsFixed(0)} kcal de hoje. Bom trabalho.',
      );
    }
    final remaining = (goal - consumed).clamp(0, double.infinity);
    return (
      title: 'Quase lá',
      body: 'Faltam ${remaining.toStringAsFixed(0)} kcal para o teu objetivo.',
    );
  }
}

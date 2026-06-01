import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications`. All notification
/// plumbing in one place so callers (settings UI, provider hooks) don't have
/// to touch the plugin directly.
///
/// **Daily reminder** uses a single notification id ([_dailyId]); calling
/// [scheduleDailyReminder] cancels and re-arms in one call so reschedules
/// are idempotent. Uses `matchDateTimeComponents: DateTimeComponents.time`
/// to auto-repeat every 24h once scheduled.
///
/// **Web** is a no-op — `flutter_local_notifications` has no web backend.
/// [init] and the public methods short-circuit instead of throwing.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyId = 1000;
  static const String _channelId = 'daily_goal';
  static const String _channelName = 'Lembrete diário';
  static const String _channelDescription =
      'Resumo do progresso do dia em relação aos objetivos';

  static bool _initialized = false;

  /// Loads tz database, sets local zone, registers platform channels +
  /// callback. Call once from `main()` before `runApp`. Safe to call again.
  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      logger.d('NotificationService: web, no-op');
      return;
    }

    tzdata.initializeTimeZones();
    // Pinned to Europe/Lisbon — university project, single locale. Swap to
    // `flutter_timezone` package later if shipping multi-region.
    tz.setLocalLocation(tz.getLocation('Europe/Lisbon'));

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      // We ask for permissions explicitly via [requestPermission], not on
      // init, so the user sees the prompt at a meaningful moment.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );
    _initialized = true;
    logger.d('NotificationService: initialized');
  }

  /// Asks the user to grant notification permission. Returns true when at
  /// least one of the platform-specific requests succeeds (per platform
  /// what "success" means: iOS = alert+sound granted; Android 13+ =
  /// POST_NOTIFICATIONS granted; older Android always returns true).
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final androidGranted =
        await android?.requestNotificationsPermission() ?? true;

    logger.d(
      'NotificationService: permission → iOS=$iosGranted android=$androidGranted',
    );
    return iosGranted && androidGranted;
  }

  /// Cancels the existing daily reminder (if any) and schedules a new one
  /// at [time] today (or tomorrow when [time] is already past). Repeats
  /// daily after the first fire.
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    await _plugin.cancel(_dailyId);

    final scheduled = _nextOccurrenceOf(time);
    logger.d('NotificationService: scheduling daily reminder at $scheduled');

    await _plugin.zonedSchedule(
      _dailyId,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Repeat every 24h once the first fire passes.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/',
    );
  }

  /// Immediate one-shot notification — useful as a manual test from a debug
  /// button. Bypasses the schedule entirely.
  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Cancels every pending notification this app has scheduled.
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    logger.d('NotificationService: cancelAll');
    await _plugin.cancelAll();
  }

  // --- internals ---

  /// First future occurrence of [time] in the local zone. If [time] is
  /// already past today, returns the same time tomorrow so the schedule
  /// never fires immediately on registration.
  static tz.TZDateTime _nextOccurrenceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var fire = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (fire.isBefore(now)) fire = fire.add(const Duration(days: 1));
    return fire;
  }

  /// Tap handler. Reads the route payload (e.g. `/`) and pushes via the
  /// singleton [appRouter] reference. Null-safe: on cold launch the
  /// router hasn't been built yet — splash → auth-redirect resolves to the
  /// right screen anyway, so no extra cold-launch handling is needed.
  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    logger.d('NotificationService: tapped, payload=$payload');
    if (payload == null || payload.isEmpty) return;
    appRouter?.go(payload);
  }
}

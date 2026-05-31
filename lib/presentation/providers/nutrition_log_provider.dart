import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/notifications/notification_coordinator.dart';
import 'package:nutri_scan/data/repositories/nutrition_log_repository_impl.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

NutritionLog _emptyLog(String date, AppUser user) => NutritionLog(
  date: date,
  entries: const [],
  waterMl: 0,
  goals: user.nutritionGoals ??
      const NutritionGoals(calories: 2000, protein: 150, carbs: 250, fat: 65, water: 2000),
);

class NutritionLogsNotifier extends AsyncNotifier<List<NutritionLog>> {
  final repo = NutritionLogRepositoryImpl();
  int _daysLoaded = 7;

  @override
  Future<List<NutritionLog>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      logger.d('NutritionLogs: no user, empty list');
      return [];
    }
    return _fetch(user.uid, _daysLoaded);
  }



  Future<List<NutritionLog>> _fetch(String uid, int days) async {
    final now = DateTime.now();
    final dates = List.generate(days, (i) => dateKey(now.subtract(Duration(days: i)))).reversed.toList();
    logger.d('NutritionLogs: fetching last $days days (${dates.first} → ${dates.last})');
    List<NutritionLog> logs = await repo.getLogs(uid, dates);
    logger.d('NutritionLogs: fetched ${logs.length} logs');
    return logs;
  }

  /// Extend the loaded window by [extraDays] more days. Keeps the current
  /// list in [state] while the additional days are fetched so the UI doesn't
  /// flash an empty/loading state during infinite-scroll pagination.
  Future<void> loadMore({int extraDays = 7}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    _daysLoaded += extraDays;
    logger.d('NutritionLogs: loadMore → $_daysLoaded days total');
    try {
      final logs = await _fetch(user.uid, _daysLoaded);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      logger.e('NutritionLogs: loadMore error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setRange(int days) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    _daysLoaded = days;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(user.uid, _daysLoaded));
  }

  int get daysLoaded => _daysLoaded;

  // --- mutations: refresh just the affected date and splice into list ---

  Future<void> _refreshDate(AppUser user, String date) async {
    NutritionLog? updated = await repo.getLog(user.uid, date);

    // Auto-cleanup: if the doc still exists but is fully empty (no entries
    // AND no water logged), delete it so the day disappears from the list
    // instead of leaving an empty placeholder behind. Goals snapshot alone
    // isn't worth keeping.
    if (updated != null &&
        updated.entries.isEmpty &&
        updated.waterMl == 0) {
      logger.d('NutritionLogs: auto-deleting empty log on $date');
      await repo.deleteLog(user.uid, date);
      updated = null;
    }

    final current = state.value ?? [];
    final filtered = [for (final l in current) if (l.date != date) l];
    final newList = updated == null
        ? filtered
        : ([...filtered, updated]..sort((a, b) => a.date.compareTo(b.date)));
    state = AsyncValue.data(newList);

    // Reschedule today's reminder so its body reflects the latest totals.
    // No-op when the user hasn't enabled notifications.
    await _maybeReschedule(user, newList);
  }

  /// Fire-and-forget reschedule of the daily reminder. Skips silently when
  /// notifications are disabled or the date being mutated isn't today (no
  /// reason to refresh the message for a past day's edit).
  Future<void> _maybeReschedule(
    AppUser user,
    List<NutritionLog> logs,
  ) async {
    final today = todayKey();
    final todayLog = logs.where((l) => l.date == today).firstOrNull;
    final goals = user.nutritionGoals;
    if (goals == null) return;
    try {
      await NotificationCoordinator.reschedule(
        todayLog: todayLog,
        goals: goals,
      );
    } catch (e, st) {
      // Don't surface notification errors into the meal-log state.
      logger.w('NutritionLogs: reschedule failed', error: e, stackTrace: st);
    }
  }

  Future<void> addEntry(MealEntry entry, {String? date}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final d = date ?? todayKey();
    logger.d('NutritionLogs: addEntry on $d - ${entry.productName} (${entry.servingGrams}g)');
    try {
      // Pass the user's current goals so the repo can freeze them on the
      // log doc on first creation (per docs/DB.md goals-snapshot design).
      await repo.addEntry(
        user.uid,
        d,
        entry,
        goalsSnapshot: user.nutritionGoals,
      );
      await _refreshDate(user, d);
    } catch (e, st) {
      logger.e('NutritionLogs: addEntry error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeEntry(String entryId, {String? date}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final d = date ?? todayKey();
    logger.d('NutritionLogs: removeEntry $entryId on $d');
    try {
      await repo.removeEntry(user.uid, d, entryId);
      await _refreshDate(user, d);
    } catch (e, st) {
      logger.e('NutritionLogs: removeEntry error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateEntry(MealEntry entry, {String? date}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final d = date ?? todayKey();
    logger.d('NutritionLogs: updateEntry ${entry.id} on $d');
    try {
      await repo.updateEntry(user.uid, d, entry);
      await _refreshDate(user, d);
    } catch (e, st) {
      logger.e('NutritionLogs: updateEntry error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Move [entry] from [oldDate] to [newDate]. When the dates match this is
  /// equivalent to [updateEntry]; otherwise it removes the entry from the old
  /// day and re-adds it on the new one (carrying the user's current goals as
  /// the new-day goals snapshot when that doc has to be created).
  ///
  /// Not atomic - a Firestore transaction would be the right tool but the
  /// student-project scope keeps it as two sequential writes.
  Future<void> moveEntry(
    MealEntry entry, {
    required String oldDate,
    required String newDate,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    if (oldDate == newDate) {
      await updateEntry(entry, date: newDate);
      return;
    }
    logger.d('NutritionLogs: moveEntry ${entry.id} $oldDate → $newDate');
    try {
      await repo.removeEntry(user.uid, oldDate, entry.id);
      await repo.addEntry(
        user.uid,
        newDate,
        entry,
        goalsSnapshot: user.nutritionGoals,
      );
      await _refreshDate(user, oldDate);
      await _refreshDate(user, newDate);
    } catch (e, st) {
      logger.e('NutritionLogs: moveEntry error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDay(String date) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    logger.d('NutritionLogs: deleteDay $date');
    try {
      await repo.deleteLog(user.uid, date);
      final current = state.value ?? [];
      final next = [for (final l in current) if (l.date != date) l];
      state = AsyncValue.data(next);
      await _maybeReschedule(user, next);
    } catch (e, st) {
      logger.e('NutritionLogs: deleteDay error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setWater(double ml, {String? date}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final d = date ?? todayKey();
    logger.d('NutritionLogs: setWater ${ml}ml on $d');
    try {
      await repo.updateWater(
        user.uid,
        d,
        ml,
        goalsSnapshot: user.nutritionGoals,
      );
      await _refreshDate(user, d);
    } catch (e, st) {
      logger.e('NutritionLogs: setWater error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addWater(double ml, {String? date}) async {
    final d = date ?? todayKey();
    final logs = state.value ?? [];
    final current = logs.firstWhere(
      (l) => l.date == d,
      orElse: () => _emptyLog(d, ref.read(authProvider).value!),
    );
    await setWater(current.waterMl + ml, date: d);
  }
}

final nutritionLogsProvider =
    AsyncNotifierProvider<NutritionLogsNotifier, List<NutritionLog>>(NutritionLogsNotifier.new);

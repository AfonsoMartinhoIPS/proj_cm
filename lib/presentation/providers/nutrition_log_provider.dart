import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/notifications/notification_coordinator.dart';
import 'package:nutri_scan/data/repositories/nutrition_log_repository_impl.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

/// Cria um registo de nutrição vazio para uma determinada [date] e [user].
///
/// Se o utilizador não tiver metas definidas, aplica metas padrão
/// (2000 kcal, 150 g proteína, 250 g hidratos, 65 g gordura, 2000 ml água).
NutritionLog _emptyLog(String date, AppUser user) => NutritionLog(
      date: date,
      entries: const [],
      waterMl: 0,
      goals: user.nutritionGoals ??
          const NutritionGoals(
              calories: 2000, protein: 150, carbs: 250, fat: 65, water: 2000),
    );

/// Notifier que gere os registos diários de nutrição do utilizador autenticado.
///
/// Carrega inicialmente os últimos 7 dias e expõe a lista através do estado
/// assíncrono. Permite adicionar, remover, atualizar e mover entradas de
/// refeição, bem como registar o consumo de água.
class NutritionLogsNotifier extends AsyncNotifier<List<NutritionLog>> {
  final repo = NutritionLogRepositoryImpl();
  int _daysLoaded = 7;

  /// Constrói o estado inicial carregando os últimos [_daysLoaded] dias.
  ///
  /// Se o utilizador não estiver autenticado, devolve uma lista vazia.
  @override
  Future<List<NutritionLog>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      logger.d('NutritionLogs: no user, empty list');
      return [];
    }
    return _fetch(user.uid, _daysLoaded);
  }

  /// Obtém os registos de nutrição para os últimos [days] dias do
  /// utilizador com o [uid] especificado.
  Future<List<NutritionLog>> _fetch(String uid, int days) async {
    final now = DateTime.now();
    final dates = List.generate(
        days, (i) => dateKey(now.subtract(Duration(days: i)))).reversed.toList();
    logger.d(
        'NutritionLogs: fetching last $days days (${dates.first} → ${dates.last})');
    List<NutritionLog> logs = await repo.getLogs(uid, dates);
    logger.d('NutritionLogs: fetched ${logs.length} logs');
    return logs;
  }

  /// Expande a janela de dias carregados em [extraDays] e recarrega os dados.
  ///
  /// Mantém o estado atual enquanto os novos dados são obtidos, evitando
  /// que a interface pisque durante a paginação infinita.
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

  /// Define um novo número de dias a carregar e recarrega completamente os dados.
  Future<void> setRange(int days) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    _daysLoaded = days;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(user.uid, _daysLoaded));
  }

  /// Número de dias atualmente carregados.
  int get daysLoaded => _daysLoaded;

  /// Recarrega um dia específico e atualiza a lista no estado.
  ///
  /// Se o dia ficar vazio (sem entradas e sem água), o documento é
  /// automaticamente removido para evitar placeholders desnecessários.
  Future<void> _refreshDate(AppUser user, String date) async {
    NutritionLog? updated = await repo.getLog(user.uid, date);

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

  /// Adiciona uma entrada de refeição a um dia.
  ///
  /// Se [date] não for fornecida, utiliza a data atual. Congela as metas
  /// nutricionais atuais do utilizador no documento do dia (snapshot).
  Future<void> addEntry(MealEntry entry, {String? date}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final d = date ?? todayKey();
    logger.d(
        'NutritionLogs: addEntry on $d - ${entry.productName} (${entry.servingGrams}g)');
    try {
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

  /// Remove uma entrada de refeição de um dia.
  ///
  /// Se [date] não for fornecida, utiliza a data atual.
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

  /// Atualiza os dados de uma entrada de refeição existente.
  ///
  /// Se [date] não for fornecida, utiliza a data atual.
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

  /// Move uma entrada de refeição de um dia para outro.
  ///
  /// Quando [oldDate] e [newDate] são iguais, comporta-se como [updateEntry].
  /// Caso contrário, remove a entrada do dia antigo e adiciona-a ao novo,
  /// congelando as metas atuais no dia de destino.
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

  /// Apaga completamente um dia de registos.
  ///
  /// Remove o documento do dia e atualiza o estado local sem necessidade
  /// de recarregar todos os dados.
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

  /// Define a quantidade total de água para um dia específico.
  ///
  /// Se [date] não for fornecida, utiliza a data atual. Congela as metas
  /// nutricionais atuais do utilizador no documento do dia.
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

  /// Adiciona uma quantidade de água ao total do dia.
  ///
  /// Se [date] não for fornecida, utiliza a data atual. Se o dia ainda não
  /// existir, cria um registo vazio antes de adicionar a água.
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

/// Provider que expõe a lista de registos diários de nutrição do utilizador atual.
///
/// Reage automaticamente a alterações no [authProvider], recarregando os
/// dados quando o utilizador muda.
final nutritionLogsProvider =
    AsyncNotifierProvider<NutritionLogsNotifier, List<NutritionLog>>(NutritionLogsNotifier.new);
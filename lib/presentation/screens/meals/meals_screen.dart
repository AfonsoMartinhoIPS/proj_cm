import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/day_summary_card.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Modos de visualização do ecrã de refeições.
///
/// Cada valor representa o período temporal que serve de base para filtrar
/// os registos de refeições.
enum PeriodMode {
  /// Mostra apenas as refeições do dia selecionado.
  day,

  /// Mostra as refeições da semana atual, com abas para navegar entre os dias.
  week,

  /// Apresenta um calendário mensal e lista as refeições do dia escolhido.
  month,

  /// Exibe uma grelha com os doze meses do ano; ao tocar num mês, transita
  /// automaticamente para o modo [month] correspondente.
  year,
}

/// Ecrã principal de refeições.
///
/// Permite ao utilizador pesquisar refeições e visualizá‑las agrupadas por
/// dia, semana, mês ou ano.  Inclui paginação automática e um botão flutuante
/// para adicionar novas entradas.
class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

/// Estado do [MealsScreen] que gere a pesquisa, a seleção de período e a
/// lista de registos.
class _MealsScreenState extends ConsumerState<MealsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  bool _loadingMore = false;

  /// Modo de visualização atualmente selecionado.
  PeriodMode _periodMode = PeriodMode.day;

  /// Dia em foco para os modos [PeriodMode.day] e [PeriodMode.week].
  late DateTime _selectedDate;

  /// Mês exibido no calendário do modo [PeriodMode.month].
  late DateTime _displayMonth;

  /// Evita que os parâmetros da rota sejam lidos mais do que uma vez.
  bool _initializedFromRoute = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedFromRoute) {
      _readRouteParams();
      _initializedFromRoute = true;
    }
  }

  /// Lê os parâmetros `mode` e `date` da rota atual e inicializa o estado
  /// correspondente (modo de visualização e data selecionada).
  void _readRouteParams() {
    final uri = GoRouterState.of(context).uri;
    final mode = uri.queryParameters['mode'];
    final dateStr = uri.queryParameters['date'];

    if (mode != null) {
      setState(() {
        switch (mode) {
          case 'day':
            _periodMode = PeriodMode.day;
            break;
          case 'week':
            _periodMode = PeriodMode.week;
            break;
          case 'month':
            _periodMode = PeriodMode.month;
            break;
          case 'year':
            _periodMode = PeriodMode.year;
            break;
        }
      });
    }

    if (dateStr != null) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        setState(() {
          _selectedDate = parsed;
          if (_periodMode == PeriodMode.month) {
            _displayMonth = DateTime(parsed.year, parsed.month);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      await ref.read(nutritionLogsProvider.notifier).loadMore();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool _matchesQuery(NutritionLog log) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return log.entries.any((e) => e.productName.toLowerCase().contains(q));
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  DateTime _endOfWeek(DateTime date) {
    final start = _startOfWeek(date);
    return start.add(const Duration(days: 6));
  }

  /// Filtra a lista de [logs] de acordo com o [PeriodMode] ativo.
  ///
  /// - [PeriodMode.day] → apenas o dia selecionado.
  /// - [PeriodMode.week] → a semana atual (segunda a domingo).
  /// - [PeriodMode.month] → o mês representado por [_displayMonth].
  /// - [PeriodMode.year] → o ano de [_selectedDate].
  List<NutritionLog> _filterByPeriod(List<NutritionLog> logs) {
    switch (_periodMode) {
      case PeriodMode.day:
        final key = _dateKey(_selectedDate);
        return logs.where((l) => l.date == key).toList();
      case PeriodMode.week:
        final now = DateTime.now();
        final start = _startOfWeek(now);
        final end = _endOfWeek(now);
        return logs.where((l) {
          final d = DateTime.tryParse(l.date);
          if (d == null) return false;
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
      case PeriodMode.month:
        return logs.where((l) {
          final d = DateTime.tryParse(l.date);
          return d != null &&
              d.year == _displayMonth.year &&
              d.month == _displayMonth.month;
        }).toList();
      case PeriodMode.year:
        return logs.where((l) {
          final d = DateTime.tryParse(l.date);
          return d != null && d.year == _selectedDate.year;
        }).toList();
    }
  }

  /// Barra de seleção de período (Dia / Semana / Mês / Ano).
  ///
  /// Ao mudar de modo, as datas de referência são repostas para o valor atual
  /// nos modos [day] e [week], e para o mês corrente no modo [month].
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: SegmentedButton<PeriodMode>(
        segments: const [
          ButtonSegment(value: PeriodMode.day, label: Text('Dia')),
          ButtonSegment(value: PeriodMode.week, label: Text('Semana')),
          ButtonSegment(value: PeriodMode.month, label: Text('Mês')),
          ButtonSegment(value: PeriodMode.year, label: Text('Ano')),
        ],
        selected: {_periodMode},
        onSelectionChanged: (mode) {
          setState(() {
            _periodMode = mode.first;
            if (_periodMode == PeriodMode.day ||
                _periodMode == PeriodMode.week) {
              _selectedDate = DateTime.now();
            }
            if (_periodMode == PeriodMode.month) {
              _displayMonth = DateTime(
                DateTime.now().year,
                DateTime.now().month,
              );
            }
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.primary;
            }
            return Theme.of(context).colorScheme.surfaceContainerHighest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Theme.of(context).colorScheme.onPrimary;
            }
            return Theme.of(context).colorScheme.onSurfaceVariant;
          }),
        ),
      ),
    );
  }

  /// Vista de pesquisa global.
  ///
  /// Exibe uma lista plana de todos os dias que correspondem ao texto de
  /// pesquisa, independentemente do período selecionado. Se não houver
  /// resultados, apresenta um estado vazio com opção de limpar a pesquisa.
  Widget _buildSearchResults(List<NutritionLog> logs) {
    final filtered = logs.where((l) => _matchesQuery(l)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return NutriEmptyState(
        icon: Icons.search_off,
        title: 'Nenhum resultado para "$_query"',
        subtitle: 'Tenta outra pesquisa.',
        actionLabel: 'Limpar pesquisa',
        onAction: () {
          _searchController.clear();
          setState(() => _query = '');
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          return _loadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }
        final log = filtered[index];
        return DaySummaryCard(
          log: log,
          onTap: () => context.push('/meals/day/${log.date}'),
          onDelete: () async => _deleteLog(log),
        );
      },
    );
  }

  /// Vista para o modo [PeriodMode.day].
  ///
  /// Lista as refeições do dia [_selectedDate]. Se o dia não tiver refeições,
  /// exibe um estado vazio.
  Widget _buildDayView(List<NutritionLog> logs) {
    final filtered = logs.where((l) => _matchesQuery(l)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return NutriEmptyState(
        icon: Icons.restaurant_outlined,
        title: 'Nenhuma refeição neste dia',
        subtitle: 'Toca em + para adicionar',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final log = filtered[index];
        return DaySummaryCard(
          log: log,
          onTap: () => context.push('/meals/day/${log.date}'),
          onDelete: () async => _deleteLog(log),
        );
      },
    );
  }

  /// Vista para o modo [PeriodMode.week].
  ///
  /// Apresenta abas horizontais com os dias da semana atual. Ao selecionar
  /// um dia, a lista de refeições desse dia é exibida por baixo.
  Widget _buildWeekView(List<NutritionLog> logs) {
    final now = DateTime.now();
    final start = _startOfWeek(now);
    final daysOfWeek = List.generate(7, (i) => start.add(Duration(days: i)));

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            children: daysOfWeek.map((day) {
              final isSelected = _dateKey(day) == _dateKey(_selectedDate);
              final label = ptWeekdaysShort[day.weekday - 1];
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      NutriLabel(
                        label,
                        variant: NutriLabelVariant.small,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildDayView(
            logs.where((l) => l.date == _dateKey(_selectedDate)).toList(),
          ),
        ),
      ],
    );
  }

  /// Vista para o modo [PeriodMode.month].
  ///
  /// Desenha um calendário mensal navegável. Os dias com refeições são
  /// assinalados com um pequeno ponto. Ao tocar num dia, as refeições
  /// correspondentes são listadas por baixo do calendário.
  Widget _buildMonthView(List<NutritionLog> logs) {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    final cells = <Widget>[];
    for (var i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayMonth.year, _displayMonth.month, day);
      final isToday = _dateKey(date) == _dateKey(DateTime.now());
      final isSelected = _dateKey(date) == _dateKey(_selectedDate);
      final hasMeals = logs.any((log) => log.date == _dateKey(date));

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : hasMeals
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : isToday
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasMeals)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final selectedDayLogs = logs
        .where((l) => l.date == _dateKey(_selectedDate))
        .toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month - 1,
                  );
                }),
              ),
              NutriLabel(
                '${ptMonthsFull[_displayMonth.month - 1]} ${_displayMonth.year}',
                variant: NutriLabelVariant.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _displayMonth = DateTime(
                    _displayMonth.year,
                    _displayMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ptWeekdaysShort
                .map(
                  (e) => Expanded(
                    child: Center(
                      child: Text(
                        e,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
          const Divider(),
          if (selectedDayLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
              child: NutriEmptyState(
                icon: Icons.restaurant_outlined,
                title: 'Nenhuma refeição',
                subtitle: formatDmy(_selectedDate),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayLogs.length,
              itemBuilder: (context, index) {
                final log = selectedDayLogs[index];
                return DaySummaryCard(
                  log: log,
                  onTap: () => context.push('/meals/day/${log.date}'),
                  onDelete: () async => _deleteLog(log),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Vista para o modo [PeriodMode.year].
  ///
  /// Apresenta os doze meses do ano numa grelha de 3 colunas. Cada célula
  /// mostra o nome do mês e a quantidade de refeições registadas. Ao tocar
  /// num mês, o ecrã transita para o modo [PeriodMode.month] correspondente.
  Widget _buildYearView(List<NutritionLog> logs) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(AppSizes.md),
      children: List.generate(12, (index) {
        final month = index + 1;
        final monthLogs = logs.where((l) {
          final d = DateTime.tryParse(l.date);
          return d != null && d.year == _selectedDate.year && d.month == month;
        }).length;
        return GestureDetector(
          onTap: () {
            setState(() {
              _displayMonth = DateTime(_selectedDate.year, month);
              _periodMode = PeriodMode.month;
            });
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NutriLabel(
                  ptMonthsFull[month - 1],
                  variant: NutriLabelVariant.body,
                ),
                if (monthLogs > 0)
                  NutriLabel(
                    '$monthLogs refeições',
                    variant: NutriLabelVariant.small,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Elimina um dia completo de refeições após confirmação do utilizador.
  ///
  /// Exibe um diálogo de confirmação e, se aceite, remove o [log] através do
  /// [nutritionLogsProvider]. Após a remoção, mostra uma snackbar informativa.
  Future<void> _deleteLog(NutritionLog log) async {
    final ok = await showNutriConfirmDialog(
      context,
      title: 'Apagar dia?',
      body:
          'Vai remover ${log.entries.length} '
          '${log.entries.length == 1 ? 'refeição' : 'refeições'} '
          'registadas em ${formatRelativeDate(log.date)}.',
    );
    if (!ok || !mounted) return;
    await ref.read(nutritionLogsProvider.notifier).deleteDay(log.date);
    if (!mounted) return;
    NutriFeedback.showInfo(context, 'Dia removido');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(nutritionLogsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(showBackButton: false, title: 'Refeições'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () => context.push('/meals/add'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: NutriTextField(
                label: 'Pesquisar',
                hint: 'Nome do produto…',
                icon: Icons.search,
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            if (_query.isEmpty) _buildPeriodSelector(),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: NutriLabel(
                    'Erro: $e',
                    variant: NutriLabelVariant.body,
                    color: colorScheme.error,
                  ),
                ),
                data: (logs) {
                  if (_query.isNotEmpty) {
                    return _buildSearchResults(logs);
                  }

                  final filteredByPeriod = _filterByPeriod(logs);
                  final searched = filteredByPeriod
                      .where((l) => _matchesQuery(l))
                      .toList();

                  switch (_periodMode) {
                    case PeriodMode.day:
                      return _buildDayView(searched);
                    case PeriodMode.week:
                      return _buildWeekView(searched);
                    case PeriodMode.month:
                      return _buildMonthView(searched);
                    case PeriodMode.year:
                      return _buildYearView(searched);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/core/utils/date_format.dart

/// Dias da semana em português (por extenso).
const ptWeekdays = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

/// Abreviaturas dos dias da semana em português.
const ptWeekdaysShort = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// Abreviaturas dos meses do ano em português.
const ptMonths = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
];

/// Nomes dos meses do ano em português (por extenso).
const ptMonthsFull = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// "DD/MM/YYYY" from a YYYY-MM-DD string.
String formatDmyFromIso(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

/// "DD/MM/YYYY" from a [DateTime].
String formatDmy(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// "Hoje" / "Ontem" / "DD/MM/YYYY" from a YYYY-MM-DD string.
String formatRelativeDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final today = DateTime.now();
  final t = DateTime(today.year, today.month, today.day);
  final logDay = DateTime(d.year, d.month, d.day);
  final diff = t.difference(logDay).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  return formatDmyFromIso(iso);
}

/// "Segunda-feira, 7 Mai" - PT long-form header date.
String formatPtHeader(DateTime d) {
  return '${ptWeekdays[d.weekday - 1]}, ${d.day} ${ptMonths[d.month - 1]}';
}
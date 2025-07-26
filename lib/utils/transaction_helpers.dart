import '../domain/models/transaction.dart';

String formatCurrency(double value, bool isIncome) {
  return isIncome
      ? 'R\$ ${value.toStringAsFixed(2)}'
      : '-R\$ ${value.toStringAsFixed(2)}';
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

String getMonthName(int month) {
  return [
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
  ][month - 1];
}

Map<String, List<TransactionModel>> groupByMonth(
  List<TransactionModel> transactions,
) {
  final Map<String, List<TransactionModel>> grouped = {};

  for (final transaction in transactions) {
    final date = transaction.date.toDate();
    final monthYear = '${getMonthName(date.month)} ${date.year}';
    grouped.putIfAbsent(monthYear, () => []).add(transaction);
  }

  return grouped;
}

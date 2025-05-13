import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/models/transaction_mode.dart';
import 'package:tech_challenge_flutter/screens/transaction_mock.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupByMonth(transactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Transações'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  groupedTransactions.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMesHeader(entry.key),
                        ...entry.value
                            .map(
                              (transaction) => _buildTransacao(
                                transaction.description,
                                _formatDate(transaction.date),
                                transaction.amount,
                                transaction.type,
                              ),
                            )
                            .toList(),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    transactions =
        transactionsMock.map((json) => Transaction.fromJson(json)).toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildMesHeader(String mes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[100],
      child: Text(
        mes,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTransacao(
    String descricao,
    String data,
    double valor,
    String tipo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descricao,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Text(
            valor >= 0
                ? 'R\$${valor.toStringAsFixed(2)}'
                : '-R\$${(-valor).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valor >= 0 ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
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

  Map<String, List<Transaction>> _groupByMonth(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final monthYear =
          '${_getMonthName(transaction.date.month)} ${transaction.date.year}';
      grouped.putIfAbsent(monthYear, () => []).add(transaction);
    }

    return grouped;
  }
}

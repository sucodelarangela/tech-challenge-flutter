import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:tech_challenge_flutter/models/transaction_mode.dart';
import 'package:tech_challenge_flutter/screens/transaction_mock.dart';
=======
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/models/auth_provider.dart';
import 'package:tech_challenge_flutter/models/transaction.dart';
import 'package:tech_challenge_flutter/models/transaction_provider.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
>>>>>>> main
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late List<Transaction> transactions;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final groupedTransactions = _groupByMonth(transactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 3.0,
              radius: const Radius.circular(4),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.green, // Verde suave
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  children:
                      groupedTransactions.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMesHeader(entry.key),
                            ...entry.value
                                .map(
                                  (transaction) => _buildTranstions(
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
        ),
      ),
    );
=======
    final isAuth = Provider.of<AuthProvider>(context).isAuth;

    return !isAuth
        ? LoginScreen()
        : Scaffold(
          appBar: AppBar(
            title: Text('Transações'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.TRANSACTION_FORM);
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),

          drawer: MainDrawer(),

          body: Column(
            children: [
              Text('GUILHERME, ajustar com o que você já fez'),
              FutureBuilder<List<TransactionModel>>(
                future:
                    Provider.of<TransactionProvider>(context).getTransactions(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar transações.'));
                  }

                  final transactions = snapshot.data ?? [];

                  if (transactions.isEmpty) {
                    return Center(child: Text('Nenhuma transação encontrada.'));
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (ctx, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          leading:
                              transaction.image.isNotEmpty
                                  ? Image.network(
                                    transaction.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                  : Icon(Icons.receipt_long),
                          title: Text(transaction.description),
                          subtitle: Text(
                            'R\$ ${transaction.value.toStringAsFixed(2)} - ${transaction.category}',
                          ),
                          trailing: Text(
                            transaction.date.toDate().toString().split(' ')[0],
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
>>>>>>> main
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Widget _buildTranstions(
    String descricao,
    String data,
    double valor,
    String tipo,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/components/filter/filter_modal.dart';
import 'package:tech_challenge_flutter/core/providers/auth_provider.dart';
import 'package:tech_challenge_flutter/core/providers/transaction_provider.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/utils/transaction_helpers.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';
import 'package:tech_challenge_flutter/widgets/month_header.dart';
import 'package:tech_challenge_flutter/widgets/transaction_item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../core/models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _filterCategory;
  int? _filterMonth;

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<AuthProvider>(context).isAuth;

    if (!isAuth) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          IconButton(
            onPressed: _showFilterModal,
            icon: Icon(
              Icons.filter_alt,
              color:
                  _filterCategory != null || _filterMonth != null
                      ? Colors.blue
                      : Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.TRANSACTION_FORM);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          if (_filterCategory != null || _filterMonth != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Text(
                    _buildFilterText(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilter,
                    child: Text(
                      'Limpar',
                      style: TextStyle(
                        color: Colors.blue[800],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<TransactionProvider>(
                builder: (ctx, transactionProvider, _) {
                  if (transactionProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (transactionProvider.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar transações: ${transactionProvider.error}',
                      ),
                    );
                  }

                  final transactions = _getFilteredTransactions(
                    transactionProvider.transactions!,
                  );

                  if (transactions.isEmpty) {
                    return Center(child: Text(_buildEmptyListMessage()));
                  }

                  final groupedTransactions = _groupByMonth(transactions);

                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 3.0,
                        radius: const Radius.circular(4),
                        child: GlowingOverscrollIndicator(
                          axisDirection: AxisDirection.down,
                          color: Colors.green,
                          child: ListView(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            children:
                                groupedTransactions.entries.map((entry) {
                                  return SlidableAutoCloseBehavior(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MonthHeader(month: entry.key),
                                        ...entry.value.map(
                                          (transaction) => Slidable(
                                            key: ValueKey(transaction.id),
                                            endActionPane: ActionPane(
                                              motion: const ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (_) async {
                                                    final confirm = await showDialog<
                                                      bool
                                                    >(
                                                      context: context,
                                                      builder:
                                                          (ctx) => AlertDialog(
                                                            title: const Text(
                                                              'Excluir Transação?',
                                                            ),
                                                            content: const Text(
                                                              'Tem certeza de que quer remover a transação? Esta ação é irreversível.',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.of(
                                                                      context,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Não',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () => Navigator.of(
                                                                      context,
                                                                    ).pop(true),
                                                                child:
                                                                    const Text(
                                                                      'Sim',
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                    );

                                                    if (confirm == true) {
                                                      _deleteTransaction(
                                                        transaction.id,
                                                      );
                                                    }
                                                  },
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.error,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                ),
                                                SlidableAction(
                                                  onPressed: (_) {
                                                    Navigator.of(
                                                      context,
                                                    ).pushNamed(
                                                      AppRoutes
                                                          .TRANSACTION_FORM,
                                                      arguments: transaction,
                                                    );
                                                  },
                                                  backgroundColor:
                                                      Colors.cyan.shade700,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.edit,
                                                ),
                                                if (transaction
                                                    .image
                                                    .isNotEmpty)
                                                  SlidableAction(
                                                    onPressed: (_) {},
                                                    backgroundColor:
                                                        Colors.green,
                                                    foregroundColor:
                                                        Colors.white,
                                                    icon: Icons.attach_file,
                                                  ),
                                              ],
                                            ),
                                            child: TransactionItem(
                                              description:
                                                  transaction.description,
                                              date: formatDate(
                                                transaction.date.toDate(),
                                              ),
                                              value: transaction.value,
                                              isIncome: transaction.isIncome,
                                              imageUrl: transaction.image,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> allTransactions,
  ) {
    if (_filterCategory == null && _filterMonth == null) {
      return allTransactions;
    }

    return allTransactions.where((transaction) {
      final date = transaction.date.toDate();
      final categoryMatch =
          _filterCategory == null
              ? true
              : _filterCategory == 'Entrada'
              ? transaction.isIncome
              : !transaction.isIncome;
      final monthMatch =
          _filterMonth == null ? true : date.month == _filterMonth;
      return categoryMatch && monthMatch;
    }).toList();
  }

  String _buildEmptyListMessage() {
    if (_filterCategory != null && _filterMonth != null) {
      return 'Nenhuma transação encontrada para "$_filterCategory" em ${getMonthName(_filterMonth!)}';
    } else if (_filterCategory != null) {
      return 'Nenhuma transação encontrada para "$_filterCategory"';
    } else if (_filterMonth != null) {
      return 'Nenhuma transação encontrada para ${getMonthName(_filterMonth!)}';
    } else {
      return 'Nenhuma transação encontrada.';
    }
  }

  String _buildFilterText() {
    final categoryText =
        _filterCategory != null ? 'Categoria: $_filterCategory' : '';
    final monthText =
        _filterMonth != null ? 'Mês: ${getMonthName(_filterMonth!)}' : '';

    if (categoryText.isNotEmpty && monthText.isNotEmpty) {
      return '$categoryText | $monthText';
    } else if (categoryText.isNotEmpty) {
      return categoryText;
    } else {
      return monthText;
    }
  }

  void _clearFilter() {
    setState(() {
      _filterCategory = null;
      _filterMonth = null;
    });
  }

  Map<String, List<TransactionModel>> _groupByMonth(
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

  void _deleteTransaction(String id) async {
    try {
      final _provider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      await _provider.deleteTransaction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transação excluída com sucesso!')),
      );
    } catch (error) {
      // TODO: Verificar como retornar o erro do service
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir transação')));
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return FilterModal(
          currentFilter: _filterCategory,
          currentMonthFilter: _filterMonth,
          onCategoryFilterApplied: (newCategoryFilter) {
            setState(() {
              _filterCategory = newCategoryFilter;
            });
          },
          onMonthFilterApplied: (newMonthFilter) {
            setState(() {
              _filterMonth = newMonthFilter;
            });
          },
        );
      },
    );
  }
}

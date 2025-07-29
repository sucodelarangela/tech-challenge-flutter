import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/components/filter/filter_modal.dart';
import 'package:tech_challenge_flutter/controllers/auth_controller.dart';
import 'package:tech_challenge_flutter/controllers/transaction_controller.dart';
import 'package:tech_challenge_flutter/screens/login_screen.dart';
import 'package:tech_challenge_flutter/utils/app_routes.dart';
import 'package:tech_challenge_flutter/utils/transaction_helpers.dart';
import 'package:tech_challenge_flutter/widgets/main_drawer.dart';

import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_body.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _filterCategory;
  int? _filterMonth;
  bool isLocalLoading = true;

  String getFilename(TransactionModel transaction) {
    final name = transaction.description.replaceAll(' ', '_');
    final date = transaction.date.toDate().toString().replaceAll('/', '_');
    return '$date-$name';
  }

  void _downloadImage(String imageUrl, String fileName) async {
    final _provider = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    setState(() => isLocalLoading = true);
    final result = await _provider.downloadImage(imageUrl, fileName);
    if (result != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
    setState(() => isLocalLoading = false);
  }

  @override
  void initState() {
    super.initState();
    final _provider = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<AuthController>(context).isAuth;

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
      body: TransactionBody(
        filterCategory: _filterCategory,
        filterMonth: _filterMonth,
        onClearFilter: _clearFilter,
        getFilteredTransactions: _getFilteredTransactions,
        groupByMonth: _groupByMonth,
        onDeleteTransaction: _deleteTransaction,
        onEditTransaction: (transaction) {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.TRANSACTION_FORM, arguments: transaction);
        },
        onDownloadImage: _downloadImage,
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
      final _provider = Provider.of<TransactionController>(
        context,
        listen: false,
      );
      await _provider.deleteTransaction(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transação excluída com sucesso!')),
      );
    } catch (error) {
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

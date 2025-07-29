import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/controllers/transaction_controller.dart';
import 'package:tech_challenge_flutter/utils/transaction_helpers.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_filter_banner.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_grouped_list.dart';

class TransactionBody extends StatelessWidget {
  final String? filterCategory;
  final int? filterMonth;
  final VoidCallback onClearFilter;
  final List<TransactionModel> Function(List<TransactionModel>)
  getFilteredTransactions;
  final Map<String, List<TransactionModel>> Function(List<TransactionModel>)
  groupByMonth;
  final void Function(String) onDeleteTransaction;
  final void Function(TransactionModel) onEditTransaction;
  final void Function(String imageUrl, String fileName) onDownloadImage;

  const TransactionBody({
    required this.filterCategory,
    required this.filterMonth,
    required this.onClearFilter,
    required this.getFilteredTransactions,
    required this.groupByMonth,
    required this.onDeleteTransaction,
    required this.onEditTransaction,
    required this.onDownloadImage,
    Key? key,
  }) : super(key: key);

  String _buildFilterText() {
    final categoryText =
        filterCategory != null ? 'Categoria: $filterCategory' : '';
    final monthText =
        filterMonth != null ? 'Mês: ${getMonthName(filterMonth!)}' : '';

    if (categoryText.isNotEmpty && monthText.isNotEmpty) {
      return '$categoryText | $monthText';
    } else if (categoryText.isNotEmpty) {
      return categoryText;
    } else {
      return monthText;
    }
  }

  String _buildEmptyListMessage() {
    if (filterCategory != null && filterMonth != null) {
      return 'Nenhuma transação encontrada para "$filterCategory" em ${getMonthName(filterMonth!)}';
    } else if (filterCategory != null) {
      return 'Nenhuma transação encontrada para "$filterCategory"';
    } else if (filterMonth != null) {
      return 'Nenhuma transação encontrada para ${getMonthName(filterMonth!)}';
    } else {
      return 'Nenhuma transação encontrada.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    return Column(
      children: [
        if (filterCategory != null || filterMonth != null)
          TransactionFilterBanner(
            filterCategory: filterCategory,
            filterMonth: filterMonth,
            filterText: _buildFilterText(),
            onClear: onClearFilter,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<TransactionController>(
              builder: (ctx, transactionProvider, _) {
                transactionProvider.isLoading
                    ? ctx.loaderOverlay.show()
                    : ctx.loaderOverlay.hide();

                if (transactionProvider.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar transações: ${transactionProvider.error}',
                    ),
                  );
                }

                final transactions = getFilteredTransactions(
                  transactionProvider.transactions!,
                );

                if (transactions.isEmpty) {
                  return Center(child: Text(_buildEmptyListMessage()));
                }

                final groupedTransactions = groupByMonth(transactions);

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
                        child: TransactionGroupedList(
                          scrollController: _scrollController,
                          groupedTransactions: groupedTransactions,
                          onEdit: onEditTransaction,
                          onDelete: onDeleteTransaction,
                          onDownload: onDownloadImage,
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
    );
  }
}

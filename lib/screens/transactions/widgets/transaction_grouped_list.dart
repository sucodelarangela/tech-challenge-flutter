import 'package:flutter/material.dart';
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/utils/transaction_helpers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tech_challenge_flutter/widgets/month_header.dart';
import 'package:tech_challenge_flutter/widgets/transaction_item.dart';

class TransactionGroupedList extends StatelessWidget {
  final Map<String, List<TransactionModel>> groupedTransactions;
  final void Function(TransactionModel) onEdit;
  final void Function(String) onDelete;
  final void Function(String imageUrl, String fileName) onDownload;
  final ScrollController? scrollController;

  const TransactionGroupedList({
    required this.groupedTransactions,
    required this.onEdit,
    required this.onDelete,
    required this.onDownload,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  String _getFilename(TransactionModel transaction) {
    final name = transaction.description.replaceAll(' ', '_');
    final date = transaction.date.toDate().toString().replaceAll('/', '_');
    return '$date-$name';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children:
          groupedTransactions.entries.map((entry) {
            return SlidableAutoCloseBehavior(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Excluir Transação?'),
                                      content: const Text(
                                        'Tem certeza de que quer remover a transação? Esta ação é irreversível.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text('Sim'),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                onDelete(transaction.id);
                              }
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            onPressed: (_) => onEdit(transaction),
                            backgroundColor: Colors.cyan.shade700,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                          ),
                          if (transaction.image.isNotEmpty)
                            SlidableAction(
                              onPressed:
                                  (_) => onDownload(
                                    transaction.image,
                                    _getFilename(transaction),
                                  ),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.attach_file,
                            ),
                        ],
                      ),
                      child: TransactionItem(
                        description: transaction.description,
                        date: formatDate(transaction.date.toDate()),
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
    );
  }
}

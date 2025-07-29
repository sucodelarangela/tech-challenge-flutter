import 'package:flutter/material.dart';

class TransactionFilterBanner extends StatelessWidget {
  final String? filterCategory;
  final int? filterMonth;
  final String filterText;
  final VoidCallback onClear;

  const TransactionFilterBanner({
    required this.filterCategory,
    required this.filterMonth,
    required this.filterText,
    required this.onClear,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blue[50],
      child: Row(
        children: [
          Text(
            filterText,
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClear,
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
    );
  }
}

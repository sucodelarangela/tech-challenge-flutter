import 'package:flutter/material.dart';

import '../utils/transaction_helpers.dart';

class TransactionItem extends StatelessWidget {
  final String description;
  final String date;
  final double value;
  final bool isIncome;
  final String? imageUrl;

  const TransactionItem({
    super.key,
    required this.description,
    required this.date,
    required this.value,
    required this.isIncome,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
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
                description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                spacing: 8,
                children: [
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Transform.rotate(
                      angle: 70,
                      child: Icon(Icons.attach_file, size: 16),
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(value, isIncome),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }
}

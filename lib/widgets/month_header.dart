import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final String month;

  const MonthHeader({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.grey[100],
      child: Text(
        month,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}

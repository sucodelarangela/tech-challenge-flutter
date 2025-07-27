import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePieChartCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;

  const HomePieChartCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: totalIncome,
                title: 'Entradas\nR\$ ${totalIncome.toStringAsFixed(2)}',
                color: Colors.green,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              PieChartSectionData(
                value: totalExpenses,
                title: 'Saídas\nR\$ ${totalExpenses.toStringAsFixed(2)}',
                color: Colors.red,
                radius: 60,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

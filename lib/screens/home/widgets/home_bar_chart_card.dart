import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeBarChartCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;

  const HomeBarChartCard({
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
        padding: const EdgeInsets.only(
          top: 42.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: SizedBox.expand(
          child: Center(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: totalIncome,
                        color: Colors.green,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: totalExpenses,
                        color: Colors.red,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchCallback: (event, response) {},
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFFF0F0F0),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final value = rod.toY.toStringAsFixed(2);
                      return BarTooltipItem(
                        'R\$ $value',
                        const TextStyle(color: Colors.black87, fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 1000 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Entrada');
                          case 1:
                            return const Text('Saída');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/expense_provider.dart';

class ExpenseChartWidget extends StatelessWidget {
  final ExpenseProvider provider;

  const ExpenseChartWidget({super.key, required this.provider});

  static const List<Color> _chartColors = [
    Color(0xFFE53935),
    Color(0xFF8E24AA),
    Color(0xFF3949AB),
    Color(0xFF00ACC1),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF6D4C41),
    Color(0xFFD81B60),
    Color(0xFF5E35B1),
    Color(0xFF1E88E5),
  ];

  @override
  Widget build(BuildContext context) {
    final byCategory = provider.expensesByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final total = byCategory.values.fold(0.0, (sum, v) => sum + v);
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending by Category',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: entries.asMap().entries.map((e) {
                          final index = e.key;
                          final entry = e.value;
                          final percentage = (entry.value / total) * 100;

                          return PieChartSectionData(
                            color: _chartColors[index % _chartColors.length],
                            value: entry.value,
                            title:
                                '${percentage.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.asMap().entries.map((e) {
                      final index = e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _chartColors[
                                    index % _chartColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              provider.getCategoryName(entry.key),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

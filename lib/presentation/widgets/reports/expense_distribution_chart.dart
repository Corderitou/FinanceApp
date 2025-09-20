import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/reports/report_models.dart';

class ExpenseDistributionChart extends StatelessWidget {
  final List<CategoryExpense> categoryExpenses;

  const ExpenseDistributionChart({
    Key? key,
    required this.categoryExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución de Gastos por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (categoryExpenses.isEmpty) {
      return const Center(
        child: Text('No hay datos de gastos para mostrar'),
      );
    }

    double total = 0.0;
    for (var item in categoryExpenses) {
      total += item.amount;
    }
    
    return PieChart(
      PieChartData(
        sections: categoryExpenses.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final percentage = total > 0 ? (category.amount / total) * 100 : 0;
          
          return PieChartSectionData(
            color: _getColorFromHex(category.color),
            value: category.amount,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    // Remove the # if present
    hexColor = hexColor.replaceAll('#', '');
    
    // If hex color is 6 characters, add alpha channel
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    
    // Parse and return color
    try {
      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      // Return a default color if parsing fails
      return Colors.grey;
    }
  }
}
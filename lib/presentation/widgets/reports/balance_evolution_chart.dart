import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/reports/report_models.dart';

class BalanceEvolutionChart extends StatelessWidget {
  final List<BalanceEvolutionPoint> balancePoints;

  const BalanceEvolutionChart({
    Key? key,
    required this.balancePoints,
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
              'Evolución del Balance',
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
    if (balancePoints.isEmpty) {
      return const Center(
        child: Text('No hay datos para mostrar'),
      );
    }

    // Convert data points to fl_chart format
    List<FlSpot> spots = balancePoints.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final point = entry.value;
      return FlSpot(index, point.balance);
    }).toList();

    // Get min and max values for Y axis
    final balances = balancePoints.map((p) => p.balance).toList();
    final minY = balances.reduce((a, b) => a < b ? a : b);
    final maxY = balances.reduce((a, b) => a > b ? a : b);
    
    // Add some padding to the Y axis
    final yRange = maxY - minY;
    final paddedMinY = minY - (yRange * 0.1);
    final paddedMaxY = maxY + (yRange * 0.1);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Show date labels for some points
                if (value.toInt() >= 0 && value.toInt() < balancePoints.length) {
                  final date = balancePoints[value.toInt()].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey),
        ),
        minX: 0,
        maxX: (balancePoints.length - 1).toDouble(),
        minY: paddedMinY,
        maxY: paddedMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
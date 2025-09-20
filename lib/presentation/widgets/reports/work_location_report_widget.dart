import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../domain/reports/work_location_report_models.dart';

class WorkLocationReportWidget extends StatelessWidget {
  final WorkLocationReportData reportData;

  const WorkLocationReportWidget({Key? key, required this.reportData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reporte de Lugares de Trabajo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Período: ${DateFormat('dd/MM/yyyy').format(reportData.startDate)} - ${DateFormat('dd/MM/yyyy').format(reportData.endDate)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Summary information
            _buildSummaryInfo(),
            const SizedBox(height: 16),
            // Frequency chart
            const Text(
              'Distribución por Frecuencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildFrequencyChart(),
            const SizedBox(height: 16),
            // Locations list
            const Text(
              'Lista de Lugares',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLocationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total Visitas', reportData.totalVisits.toString()),
        _buildSummaryItem(
            'Lugares Únicos', reportData.locations.length.toString()),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyChart() {
    if (reportData.locations.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    // Take top 5 locations for the chart
    final topLocations = reportData.locations.length > 5
        ? reportData.locations.sublist(0, 5)
        : reportData.locations;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(topLocations),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < topLocations.length) {
                    final name = topLocations[value.toInt()].locationName;
                    // Truncate long names
                    final displayName =
                        name.length > 10 ? '${name.substring(0, 7)}...' : name;
                    return Text(displayName, style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          maxY: topLocations
                  .map((location) => location.frequency)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2,
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(List<WorkLocationFrequency> locations) {
    return locations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: location.frequency.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLocationsList() {
    if (reportData.locations.isEmpty) {
      return const Center(
        child: Text('No hay lugares registrados'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Lugar')),
          DataColumn(label: Text('Frecuencia')),
          DataColumn(label: Text('Primera Visita')),
          DataColumn(label: Text('Última Visita')),
        ],
        rows: reportData.locations.map((location) {
          return DataRow(
            cells: [
              DataCell(Text(location.locationName)),
              DataCell(Text(location.frequency.toString())),
              DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(location.firstVisit))),
              DataCell(
                  Text(DateFormat('dd/MM/yyyy').format(location.lastVisit))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
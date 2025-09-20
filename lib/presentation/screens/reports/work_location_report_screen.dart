import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/reports/work_location_report_models.dart';
import '../../../data/repositories/reports/reports_repository.dart';
import '../../widgets/reports/work_location_report_widget.dart';
import 'package:intl/intl.dart';

// Provider for reports repository
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

// Provider for work location report with date range
final workLocationReportWithDatesProvider = FutureProvider.family
    .autoDispose<WorkLocationReportData, Map<String, dynamic>>(
        (ref, params) async {
  final repository = ref.read(reportsRepositoryProvider);
  final userId = params['userId'] as int;
  final start = params['start'] as DateTime;
  final end = params['end'] as DateTime;
  return repository.getWorkLocationReport(userId, start, end);
});

class WorkLocationReportScreen extends ConsumerStatefulWidget {
  final int userId;

  const WorkLocationReportScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  ConsumerState<WorkLocationReportScreen> createState() =>
      _WorkLocationReportScreenState();
}

class _WorkLocationReportScreenState
    extends ConsumerState<WorkLocationReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Default to last 30 days
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  Future<void> _selectDateRange() async {
    // Select start date
    final startDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (startDate == null) return;

    // Select end date
    final endDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (endDate == null) return;

    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Lugares de Trabajo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtrar por Fechas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Desde:'),
                                TextButton(
                                  onPressed: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _startDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      locale: const Locale('es', 'ES'),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        _startDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(_startDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hasta:'),
                                TextButton(
                                  onPressed: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _endDate,
                                      firstDate: _startDate,
                                      lastDate: DateTime.now(),
                                      locale: const Locale('es', 'ES'),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        _endDate = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(_endDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _selectDateRange,
                        child: const Text('Seleccionar Rango de Fechas'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Work Location Report
              Consumer(
                builder: (context, ref, child) {
                  final reportAsync = ref.watch(
                    workLocationReportWithDatesProvider({
                      'userId': widget.userId,
                      'start': _startDate,
                      'end': _endDate
                    }),
                  );
                  
                  return reportAsync.when(
                    data: (reportData) => WorkLocationReportWidget(reportData: reportData),
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, stack) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error al cargar reporte de lugares: $error'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
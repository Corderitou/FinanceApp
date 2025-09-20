import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/reports/report_models.dart';
import '../../../domain/reports/work_location_report_models.dart';
import '../../../data/repositories/reports/reports_repository.dart';
import '../../widgets/reports/expense_distribution_chart.dart';
import '../../widgets/reports/income_vs_expense_chart.dart';
import '../../widgets/reports/balance_evolution_chart.dart';
import '../../widgets/reports/financial_summary_widget.dart';
import '../../widgets/reports/work_location_report_widget.dart';
import 'budget_report_screen.dart';
import 'work_location_report_screen.dart';
import '../export/export_screen.dart'; // Add export screen import
import '../../../domain/entities/category.dart';

// Provider for reports repository
final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

// Provider for financial summary
final financialSummaryProvider = FutureProvider.family<FinancialSummary, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  return repository.getFinancialSummary(userId);
});

// Provider for category expenses
final categoryExpensesProvider = FutureProvider.family<List<CategoryExpense>, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  return repository.getCategoryExpenses(userId);
});

// Provider for income vs expense
final incomeVsExpenseProvider = FutureProvider.family<IncomeVsExpense, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  // Get data for the last 30 days
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return repository.getIncomeVsExpense(userId, thirtyDaysAgo, now);
});

// Provider for balance evolution
final balanceEvolutionProvider = FutureProvider.family<List<BalanceEvolutionPoint>, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  return repository.getBalanceEvolution(userId);
});

// Provider for work location report
final workLocationReportProvider = FutureProvider.family<WorkLocationReportData, int>((ref, userId) async {
  final repository = ref.read(reportsRepositoryProvider);
  // Get data for the last 30 days
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return repository.getWorkLocationReport(userId, thirtyDaysAgo, now);
});

class ReportsDashboardScreen extends ConsumerWidget {
  final int userId;
  final List<Category> categories;

  const ReportsDashboardScreen({
    Key? key,
    required this.userId,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Financieros'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExportScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Reportes Financieros',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Análisis detallado de tus finanzas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Financial Summary
                Consumer(
                  builder: (context, ref, child) {
                    final summaryAsync = ref.watch(financialSummaryProvider(userId));
                    
                    return summaryAsync.when(
                      data: (summary) => FinancialSummaryWidget(summary: summary),
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (error, stack) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error al cargar resumen: $error'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Income vs Expense Chart
                Consumer(
                  builder: (context, ref, child) {
                    final incomeVsExpenseAsync = ref.watch(incomeVsExpenseProvider(userId));
                    
                    return incomeVsExpenseAsync.when(
                      data: (data) => IncomeVsExpenseChart(incomeVsExpense: data),
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (error, stack) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error al cargar comparación: $error'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Expense Distribution Chart
                Consumer(
                  builder: (context, ref, child) {
                    final categoryExpensesAsync = ref.watch(categoryExpensesProvider(userId));
                    
                    return categoryExpensesAsync.when(
                      data: (expenses) => ExpenseDistributionChart(categoryExpenses: expenses),
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (error, stack) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error al cargar distribución: $error'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Balance Evolution Chart
                Consumer(
                  builder: (context, ref, child) {
                    final balanceEvolutionAsync = ref.watch(balanceEvolutionProvider(userId));
                    
                    return balanceEvolutionAsync.when(
                      data: (points) => BalanceEvolutionChart(balancePoints: points),
                      loading: () => const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                      error: (error, stack) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Error al cargar evolución: $error'),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Work Location Report
                Consumer(
                  builder: (context, ref, child) {
                    final workLocationReportAsync = ref.watch(workLocationReportProvider(userId));
                    
                    return workLocationReportAsync.when(
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
                const SizedBox(height: 16),
                
                // Export Data Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exportar Datos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Exporta tus transacciones y reportes en formatos CSV o PDF',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExportScreen(userId: userId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Exportar Datos'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Budget Report Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Presupuestos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Revisa cómo te estás desempeñando respecto a tus presupuestos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BudgetReportScreen(
                                    userId: userId,
                                    categories: categories,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Ver Reporte de Presupuestos'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Work Location Report Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lugares de Trabajo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Análisis de frecuencia y distribución de lugares de trabajo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkLocationReportScreen(userId: userId),
                                ),
                              );
                            },
                            child: const Text('Ver Reporte de Lugares'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
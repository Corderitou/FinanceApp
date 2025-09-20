import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/budget_progress_widget.dart';
import '../../../domain/usecases/budget/generate_budget_report_usecase.dart';
import '../../../domain/reports/budget_report.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../domain/usecases/budget/get_budget_progress_usecase.dart';

class BudgetReportScreen extends StatefulWidget {
  final int userId;
  final List<Category> categories;

  const BudgetReportScreen({
    Key? key,
    required this.userId,
    required this.categories,
  }) : super(key: key);

  @override
  _BudgetReportScreenState createState() => _BudgetReportScreenState();
}

class _BudgetReportScreenState extends State<BudgetReportScreen> {
  List<BudgetReport> _budgetReports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBudgetReports();
  }

  Future<void> _loadBudgetReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      await budgetProvider.loadBudgets(widget.userId);
      
      final generateReportUsecase = GenerateBudgetReportUsecase(BudgetRepository());
      final reports = await generateReportUsecase.execute(
        widget.userId,
        budgetProvider.budgets,
        widget.categories,
      );
      
      setState(() {
        _budgetReports = reports;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reportes: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBudgetReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgetReports.isEmpty
              ? const Center(
                  child: Text(
                    'No hay presupuestos para mostrar',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _budgetReports.length,
                  itemBuilder: (context, index) {
                    final report = _budgetReports[index];
                    final budgetProgress = BudgetProgress(
                      budget: Budget(
                        userId: widget.userId,
                        categoryId: widget.categories
                            .firstWhere(
                              (cat) => cat.name == report.categoryName,
                              orElse: () => widget.categories.first,
                            )
                            .id!,
                        amount: report.budgetAmount,
                        period: 'monthly',
                        startDate: report.periodStart,
                        endDate: report.periodEnd,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      spentAmount: report.spentAmount,
                      remainingAmount: report.remainingAmount,
                      percentage: report.percentage,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  report.categoryName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: report.percentage > 100
                                        ? Colors.red
                                        : report.percentage > 80
                                            ? Colors.orange
                                            : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${report.percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            BudgetProgressWidget(budgetProgress: budgetProgress),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Período',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${report.periodStart.day}/${report.periodStart.month}/${report.periodStart.year} - '
                                      '${report.periodEnd.day}/${report.periodEnd.month}/${report.periodEnd.year}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Restante',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '\$${report.remainingAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: report.remainingAmount < 0
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
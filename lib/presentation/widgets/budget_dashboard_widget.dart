import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import 'budget_progress_widget.dart';

class BudgetDashboardWidget extends StatelessWidget {
  final int userId;

  const BudgetDashboardWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        // Load active budgets for the current month
        WidgetsBinding.instance.addPostFrameCallback((_) {
          budgetProvider.loadActiveBudgets(userId, DateTime.now());
        });

        if (budgetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (budgetProvider.budgetProgressList.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter budgets that are close to or exceeding limits
        final criticalBudgets = budgetProvider.budgetProgressList
            .where((bp) => bp.percentage >= 80)
            .toList();

        if (criticalBudgets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alertas de Presupuesto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: criticalBudgets.length,
                  itemBuilder: (context, index) {
                    final budgetProgress = criticalBudgets[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: BudgetProgressWidget(budgetProgress: budgetProgress),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
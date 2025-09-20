import 'package:flutter/material.dart';
import '../../domain/usecases/budget/get_budget_progress_usecase.dart';

class BudgetProgressWidget extends StatelessWidget {
  final BudgetProgress budgetProgress;

  const BudgetProgressWidget({Key? key, required this.budgetProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on budget progress
    Color progressColor;
    if (budgetProgress.percentage < 50) {
      progressColor = Colors.green;
    } else if (budgetProgress.percentage < 80) {
      progressColor = Colors.orange;
    } else if (budgetProgress.percentage < 100) {
      progressColor = Colors.red;
    } else {
      progressColor = Colors.red.shade900;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (budgetProgress.percentage / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${budgetProgress.spentAmount.toStringAsFixed(2)} gastados',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '\$${budgetProgress.budget.amount.toStringAsFixed(2)} total',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${budgetProgress.percentage.toStringAsFixed(1)}% del presupuesto utilizado',
          style: TextStyle(
            fontSize: 12,
            color: progressColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (budgetProgress.percentage >= 100)
          const Text(
            '¡Presupuesto excedido!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          )
        else if (budgetProgress.percentage >= 80)
          const Text(
            '¡Cuidado! Estás cerca del límite',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
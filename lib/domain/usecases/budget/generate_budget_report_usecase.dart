import '../../../domain/entities/budget.dart';
import '../../../domain/entities/category.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../domain/reports/budget_report.dart';

class GenerateBudgetReportUsecase {
  final BudgetRepository _budgetRepository;

  GenerateBudgetReportUsecase(this._budgetRepository);

  Future<List<BudgetReport>> execute(
      int userId, List<Budget> budgets, List<Category> categories) async {
    final List<BudgetReport> reports = [];

    for (var budget in budgets) {
      final spentAmount = await _budgetRepository.getTotalSpentInCategory(
        userId,
        budget.categoryId,
        budget.startDate,
        budget.endDate,
      );

      final categoryName = categories
          .firstWhere(
            (category) => category.id == budget.categoryId,
            orElse: () => Category(
              userId: userId,
              name: 'Categoría desconocida',
              type: 'expense',
              createdAt: DateTime.now(),
            ),
          )
          .name;

      final remainingAmount = budget.amount - spentAmount;
      final percentage = budget.amount > 0 ? (spentAmount / budget.amount) * 100.0 : 0.0;

      reports.add(BudgetReport(
        categoryName: categoryName,
        budgetAmount: budget.amount,
        spentAmount: spentAmount,
        remainingAmount: remainingAmount,
        percentage: percentage,
        periodStart: budget.startDate,
        periodEnd: budget.endDate,
      ));
    }

    return reports;
  }
}
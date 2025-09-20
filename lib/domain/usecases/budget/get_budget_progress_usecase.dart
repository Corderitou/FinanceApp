import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';

class BudgetProgress {
  final Budget budget;
  final double spentAmount;
  final double remainingAmount;
  final double percentage;

  BudgetProgress({
    required this.budget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
  });
}

class GetBudgetProgressUsecase {
  final BudgetRepository _budgetRepository;

  GetBudgetProgressUsecase(this._budgetRepository);

  Future<BudgetProgress> execute(Budget budget) async {
    final spentAmount = await _budgetRepository.getTotalSpentInCategory(
      budget.userId,
      budget.categoryId,
      budget.startDate,
      budget.endDate,
    );
    
    final remainingAmount = budget.amount - spentAmount;
    final percentage = budget.amount > 0 ? (spentAmount / budget.amount) * 100 : 0;
    
    return BudgetProgress(
      budget: budget,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      percentage: percentage.toDouble(),
    );
  }
}
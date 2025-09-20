import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';

class DeleteBudgetUsecase {
  final BudgetRepository _budgetRepository;

  DeleteBudgetUsecase(this._budgetRepository);

  Future<int> execute(int budgetId) async {
    return await _budgetRepository.deleteBudget(budgetId);
  }
}
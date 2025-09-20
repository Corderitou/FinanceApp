import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';

class UpdateBudgetUsecase {
  final BudgetRepository _budgetRepository;

  UpdateBudgetUsecase(this._budgetRepository);

  Future<int> execute(Budget budget) async {
    return await _budgetRepository.updateBudget(budget);
  }
}
import '../../../../domain/entities/budget.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/repositories/budget_repository.dart';

class CreateBudgetUsecase {
  final BudgetRepository _budgetRepository;

  CreateBudgetUsecase(this._budgetRepository);

  Future<int> execute(Budget budget) async {
    return await _budgetRepository.insertBudget(budget);
  }
}
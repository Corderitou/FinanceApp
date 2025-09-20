import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';

class GetBudgetsUsecase {
  final BudgetRepository _budgetRepository;

  GetBudgetsUsecase(this._budgetRepository);

  Future<List<Budget>> execute(int userId) async {
    return await _budgetRepository.getBudgetsByUserId(userId);
  }
}
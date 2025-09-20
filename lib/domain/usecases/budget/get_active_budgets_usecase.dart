import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';

class GetActiveBudgetsUsecase {
  final BudgetRepository _budgetRepository;

  GetActiveBudgetsUsecase(this._budgetRepository);

  Future<List<Budget>> execute(int userId, DateTime date) async {
    return await _budgetRepository.getActiveBudgetsByUserId(userId, date);
  }
}
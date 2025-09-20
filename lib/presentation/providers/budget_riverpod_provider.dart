import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/usecases/budget/create_budget_usecase.dart';
import '../../domain/usecases/budget/get_budgets_usecase.dart';
import '../../domain/usecases/budget/update_budget_usecase.dart';
import '../../domain/usecases/budget/delete_budget_usecase.dart';
import '../../domain/usecases/budget/get_budget_progress_usecase.dart';
import '../../domain/usecases/budget/get_active_budgets_usecase.dart';

class BudgetState {
  final List<BudgetProgress> budgetProgressList;
  final bool isLoading;
  final String? error;

  BudgetState({
    required this.budgetProgressList,
    required this.isLoading,
    this.error,
  });

  BudgetState copyWith({
    List<BudgetProgress>? budgetProgressList,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      budgetProgressList: budgetProgressList ?? this.budgetProgressList,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  static BudgetState initial() {
    return BudgetState(
      budgetProgressList: [],
      isLoading: false,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final CreateBudgetUsecase _createBudgetUsecase = CreateBudgetUsecase(BudgetRepository());
  final GetBudgetsUsecase _getBudgetsUsecase = GetBudgetsUsecase(BudgetRepository());
  final GetActiveBudgetsUsecase _getActiveBudgetsUsecase = GetActiveBudgetsUsecase(BudgetRepository());
  final UpdateBudgetUsecase _updateBudgetUsecase = UpdateBudgetUsecase(BudgetRepository());
  final DeleteBudgetUsecase _deleteBudgetUsecase = DeleteBudgetUsecase(BudgetRepository());
  final GetBudgetProgressUsecase _getBudgetProgressUsecase = GetBudgetProgressUsecase(BudgetRepository());

  BudgetNotifier() : super(BudgetState.initial());

  Future<void> loadBudgets(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final budgets = await _getBudgetsUsecase.execute(userId);
      final budgetProgressList = <BudgetProgress>[];

      for (var budget in budgets) {
        final progress = await _getBudgetProgressUsecase.execute(budget);
        budgetProgressList.add(progress);
      }

      state = state.copyWith(
        budgetProgressList: budgetProgressList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createBudget(Budget budget) async {
    try {
      await _createBudgetUsecase.execute(budget);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _updateBudgetUsecase.execute(budget);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBudget(int budgetId, int userId) async {
    try {
      await _deleteBudgetUsecase.execute(budgetId);
      // Reload budgets after deletion
      await loadBudgets(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier();
});
import 'package:flutter/material.dart';
import '../../../domain/entities/budget.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../domain/usecases/budget/create_budget_usecase.dart';
import '../../../domain/usecases/budget/get_budgets_usecase.dart';
import '../../../domain/usecases/budget/update_budget_usecase.dart';
import '../../../domain/usecases/budget/delete_budget_usecase.dart';
import '../../../domain/usecases/budget/get_budget_progress_usecase.dart';
import '../../../domain/usecases/budget/get_active_budgets_usecase.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetRepository _budgetRepository = BudgetRepository();
  final CreateBudgetUsecase _createBudgetUsecase = CreateBudgetUsecase(BudgetRepository());
  final GetBudgetsUsecase _getBudgetsUsecase = GetBudgetsUsecase(BudgetRepository());
  final GetActiveBudgetsUsecase _getActiveBudgetsUsecase = GetActiveBudgetsUsecase(BudgetRepository());
  final UpdateBudgetUsecase _updateBudgetUsecase = UpdateBudgetUsecase(BudgetRepository());
  final DeleteBudgetUsecase _deleteBudgetUsecase = DeleteBudgetUsecase(BudgetRepository());
  final GetBudgetProgressUsecase _getBudgetProgressUsecase = GetBudgetProgressUsecase(BudgetRepository());

  List<Budget> _budgets = [];
  List<BudgetProgress> _budgetProgressList = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  List<BudgetProgress> get budgetProgressList => _budgetProgressList;
  bool get isLoading => _isLoading;

  Future<void> createBudget(Budget budget) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _createBudgetUsecase.execute(budget);
      await loadBudgets(budget.userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBudgets(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _getBudgetsUsecase.execute(userId);
      
      // Load progress for each budget
      _budgetProgressList = [];
      for (var budget in _budgets) {
        final progress = await _getBudgetProgressUsecase.execute(budget);
        _budgetProgressList.add(progress);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveBudgets(int userId, DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _getActiveBudgetsUsecase.execute(userId, date);
      
      // Load progress for each budget
      _budgetProgressList = [];
      for (var budget in _budgets) {
        final progress = await _getBudgetProgressUsecase.execute(budget);
        _budgetProgressList.add(progress);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBudget(Budget budget) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateBudgetUsecase.execute(budget);
      await loadBudgets(budget.userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBudget(int budgetId, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _deleteBudgetUsecase.execute(budgetId);
      await loadBudgets(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
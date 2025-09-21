import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../../data/models/savings_goal.dart';
import '../../data/repositories/savings_goal_repository.dart';

class SavingsGoalState {
  final List<SavingsGoal> savingsGoals;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  SavingsGoalState({
    required this.savingsGoals,
    required this.isLoading,
    this.error,
    required this.isSubmitting,
  });

  SavingsGoalState copyWith({
    List<SavingsGoal>? savingsGoals,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return SavingsGoalState(
      savingsGoals: savingsGoals ?? this.savingsGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  static SavingsGoalState initial() {
    return SavingsGoalState(
      savingsGoals: [],
      isLoading: false,
      isSubmitting: false,
    );
  }
}

class SavingsGoalNotifier extends StateNotifier<SavingsGoalState> {
  final SavingsGoalRepository _savingsGoalRepository;

  SavingsGoalNotifier({required SavingsGoalRepository savingsGoalRepository})
      : _savingsGoalRepository = savingsGoalRepository,
        super(SavingsGoalState.initial());

  Future<void> loadSavingsGoals(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final savingsGoals = await _savingsGoalRepository.getSavingsGoalsByUser(userId);
      state = state.copyWith(
        savingsGoals: savingsGoals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las metas de ahorro: ${e.toString()}',
      );
    }
  }

  Future<bool> createSavingsGoal(SavingsGoal savingsGoal) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _savingsGoalRepository.insertSavingsGoal(savingsGoal);
      
      // Reload savings goals
      await loadSavingsGoals(savingsGoal.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al crear la meta de ahorro: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateSavingsGoal(SavingsGoal savingsGoal) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _savingsGoalRepository.updateSavingsGoal(savingsGoal);
      
      // Reload savings goals
      await loadSavingsGoals(savingsGoal.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al actualizar la meta de ahorro: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteSavingsGoal(int savingsGoalId, int userId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _savingsGoalRepository.deleteSavingsGoal(savingsGoalId);
      
      // Reload savings goals
      await loadSavingsGoals(userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al eliminar la meta de ahorro: ${e.toString()}',
      );
      return false;
    }
  }
}

final savingsGoalProvider = StateNotifierProvider<SavingsGoalNotifier, SavingsGoalState>((ref) {
  // This will be overridden when the provider is created with a repository
  throw UnimplementedError();
});
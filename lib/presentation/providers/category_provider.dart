import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/models/category.dart' as model;

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  CategoryState({
    required this.categories,
    required this.isLoading,
    this.error,
    required this.isSubmitting,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  static CategoryState initial() {
    return CategoryState(
      categories: [],
      isLoading: false,
      isSubmitting: false,
    );
  }
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryNotifier({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryState.initial());

  Future<void> loadCategories(int userId) async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _categoryRepository.getCategoriesByUser(userId);
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar categorías: ${e.toString()}',
      );
    }
  }

  Future<bool> createCategory(model.Category category) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _categoryRepository.insertCategory(category);
      
      // Reload categories to include the new one
      await loadCategories(category.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al crear categoría: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateCategory(model.Category category) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _categoryRepository.updateCategory(category);
      
      // Reload categories
      await loadCategories(category.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al actualizar categoría: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId, int userId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _categoryRepository.deleteCategory(categoryId);
      
      // Reload categories
      await loadCategories(userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al eliminar categoría: ${e.toString()}',
      );
      return false;
    }
  }

  List<Category> getCategoriesByType(String type) {
    return state.categories.where((category) => category.type == type).toList();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(
    categoryRepository: CategoryRepository(),
  );
});
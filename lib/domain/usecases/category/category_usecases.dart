import '../../domain/entities/category.dart';
import '../../data/repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository _categoryRepository;

  CreateCategoryUseCase(this._categoryRepository);

  Future<int> execute(Category category) async {
    return await _categoryRepository.insertCategory(category);
  }
}

class GetCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoriesUseCase(this._categoryRepository);

  Future<List<Category>> execute(int userId) async {
    return await _categoryRepository.getCategoriesByUser(userId);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository _categoryRepository;

  UpdateCategoryUseCase(this._categoryRepository);

  Future<int> execute(Category category) async {
    return await _categoryRepository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepository;

  DeleteCategoryUseCase(this._categoryRepository);

  Future<int> execute(int categoryId) async {
    return await _categoryRepository.deleteCategory(categoryId);
  }
}

class GetCategoryByIdUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoryByIdUseCase(this._categoryRepository);

  Future<Category?> execute(int id) async {
    return await _categoryRepository.getCategoryById(id);
  }
}

class SearchCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  SearchCategoriesUseCase(this._categoryRepository);

  Future<List<Category>> execute(String query, int userId) async {
    return await _categoryRepository.searchCategoriesByName(query, userId);
  }
}
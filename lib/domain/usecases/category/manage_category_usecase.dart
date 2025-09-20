import '../../entities/category.dart' as entity;
import '../../../data/models/category.dart';
import '../../../data/repositories/category_repository.dart';

class ManageCategoryUseCase {
  final CategoryRepository categoryRepository;

  ManageCategoryUseCase({required this.categoryRepository});

  /// Get all categories for a user
  Future<List<entity.Category>> getCategoriesByUser(int userId) async {
    try {
      return await categoryRepository.getCategoriesByUser(userId);
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Get categories by type (income or expense)
  Future<List<entity.Category>> getCategoriesByType(String type) async {
    try {
      return await categoryRepository.getCategoriesByType(type);
    } catch (e) {
      throw Exception('Failed to load categories by type: $e');
    }
  }

  /// Get a specific category by ID
  Future<entity.Category?> getCategoryById(int id) async {
    try {
      return await categoryRepository.getCategoryById(id);
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }

  /// Create a new category
  Future<entity.Category> createCategory(Category category) async {
    try {
      final id = await categoryRepository.insertCategory(category);
      return category.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update an existing category
  Future<entity.Category> updateCategory(Category category) async {
    try {
      await categoryRepository.updateCategory(category);
      return category;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    try {
      // Prevent deletion of system categories
      final category = await getCategoryById(id);
      if (category != null && category.isSystemCategory) {
        throw Exception('Cannot delete system categories');
      }
      
      await categoryRepository.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Get system categories
  Future<List<entity.Category>> getSystemCategories() async {
    try {
      return await categoryRepository.getSystemCategories();
    } catch (e) {
      throw Exception('Failed to load system categories: $e');
    }
  }

  /// Initialize system categories for a new user
  Future<void> initializeSystemCategories(int userId) async {
    try {
      final existingSystemCategories = await getSystemCategories();
      
      // Check if user already has system categories
      final userCategories = await getCategoriesByUser(userId);
      final hasSystemCategories = userCategories.any((cat) => cat.isSystemCategory);
      
      if (!hasSystemCategories) {
        // Create system categories for the user
        for (var category in existingSystemCategories) {
          final userCategory = Category(
            userId: userId,
            name: category.name,
            type: category.type,
            color: category.color,
            icon: category.icon,
            createdAt: DateTime.now(),
            isSystemCategory: true,
          );
          await createCategory(userCategory);
        }
      }
    } catch (e) {
      throw Exception('Failed to initialize system categories: $e');
    }
  }
  
  /// Initialize system categories in the database (for app setup)
  Future<void> initializeSystemCategoriesInDatabase() async {
    try {
      await categoryRepository.initializeSystemCategories();
    } catch (e) {
      throw Exception('Failed to initialize system categories in database: $e');
    }
  }
}
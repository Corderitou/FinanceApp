import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/category.dart' as model;
import '../../domain/entities/category.dart' as entity;
import '../system_categories.dart';

class CategoryRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertCategory(model.Category category) async {
    final db = await dbProvider.db;
    return await db.insert('categories', category.toMap());
  }

  Future<List<model.Category>> getCategoriesByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return model.Category.fromMap(maps[i]);
    });
  }

  Future<List<model.Category>> getCategoriesByType(String type) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return model.Category.fromMap(maps[i]);
    });
  }

  Future<model.Category?> getCategoryById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return model.Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(model.Category category) async {
    final db = await dbProvider.db;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get system categories (not tied to a specific user)
  Future<List<entity.Category>> getSystemCategories() async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'is_system_category = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return model.Category.fromMap(maps[i]);
    });
  }

  /// Search categories by name
  Future<List<model.Category>> searchCategoriesByName(String query, int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ? AND name LIKE ?',
      whereArgs: [userId, '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return model.Category.fromMap(maps[i]);
    });
  }

  /// Initialize system categories in the database
  Future<void> initializeSystemCategories() async {
    final db = await dbProvider.db;
    
    // Check if system categories already exist
    final existingSystemCategories = await getSystemCategories();
    
    if (existingSystemCategories.isEmpty) {
      // Insert system categories
      final systemCategories = SystemCategoryInitializer.getSystemCategories();
      
      for (var category in systemCategories) {
        await insertCategory(category as model.Category);
      }
    }
  }
}
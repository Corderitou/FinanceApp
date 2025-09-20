import 'package:sqflite/sqflite.dart';
import '../../domain/entities/budget.dart';
import '../models/budget.dart';
import '../database/database_helper.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertBudget(Budget budget) async {
    final db = await _dbHelper.db;
    final budgetModel = BudgetModel.fromEntity(budget);
    return await db.insert('budgets', budgetModel.toMap());
  }

  Future<List<Budget>> getBudgetsByUserId(int userId) async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      final budgetModel = BudgetModel.fromMap(maps[i]);
      return Budget(
        id: budgetModel.id,
        userId: budgetModel.userId,
        categoryId: budgetModel.categoryId,
        amount: budgetModel.amount,
        period: budgetModel.period,
        startDate: budgetModel.startDate,
        endDate: budgetModel.endDate,
        createdAt: budgetModel.createdAt,
        updatedAt: budgetModel.updatedAt,
      );
    });
  }

  Future<List<Budget>> getActiveBudgetsByUserId(int userId, DateTime date) async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ? AND start_date <= ? AND end_date >= ?',
      whereArgs: [userId, date.toIso8601String(), date.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      final budgetModel = BudgetModel.fromMap(maps[i]);
      return Budget(
        id: budgetModel.id,
        userId: budgetModel.userId,
        categoryId: budgetModel.categoryId,
        amount: budgetModel.amount,
        period: budgetModel.period,
        startDate: budgetModel.startDate,
        endDate: budgetModel.endDate,
        createdAt: budgetModel.createdAt,
        updatedAt: budgetModel.updatedAt,
      );
    });
  }

  Future<Budget?> getBudgetById(int id) async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final budgetModel = BudgetModel.fromMap(maps.first);
      return Budget(
        id: budgetModel.id,
        userId: budgetModel.userId,
        categoryId: budgetModel.categoryId,
        amount: budgetModel.amount,
        period: budgetModel.period,
        startDate: budgetModel.startDate,
        endDate: budgetModel.endDate,
        createdAt: budgetModel.createdAt,
        updatedAt: budgetModel.updatedAt,
      );
    }
    return null;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await _dbHelper.db;
    final budgetModel = BudgetModel.fromEntity(budget);
    return await db.update(
      'budgets',
      budgetModel.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalSpentInCategory(int userId, int categoryId, DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.db;
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE user_id = ? 
      AND category_id = ? 
      AND type = 'expense'
      AND date BETWEEN ? AND ?
    ''', [
      userId,
      categoryId,
      startDate.toIso8601String(),
      endDate.toIso8601String()
    ]);

    return result.first['total'] != null ? result.first['total'].toDouble() : 0.0;
  }
}
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/savings_goal.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsGoalRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertSavingsGoal(SavingsGoal savingsGoal) async {
    final db = await dbProvider.db;
    return await db.insert('savings_goals', savingsGoal.toMap());
  }

  Future<List<SavingsGoal>> getSavingsGoalsByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavingsGoalModel.fromMap(maps[i]);
    });
  }

  Future<SavingsGoal?> getSavingsGoalById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavingsGoalModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSavingsGoal(SavingsGoal savingsGoal) async {
    final db = await dbProvider.db;
    return await db.update(
      'savings_goals',
      savingsGoal.toMap(),
      where: 'id = ?',
      whereArgs: [savingsGoal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SavingsGoal>> getActiveSavingsGoals(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ? AND is_completed = ?',
      whereArgs: [userId, 0],
      orderBy: 'target_date ASC',
    );

    return List.generate(maps.length, (i) {
      return SavingsGoalModel.fromMap(maps[i]);
    });
  }
}
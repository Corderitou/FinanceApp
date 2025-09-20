import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as model;
import '../../domain/entities/transaction.dart' as entity;

class TransactionRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await dbProvider.db;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await dbProvider.db;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<model.Transaction>> getTransactionsByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return model.Transaction.fromMap(maps[i]);
    });
  }

  Future<List<model.Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return model.Transaction.fromMap(maps[i]);
    });
  }

  Future<double> getTotalIncomeByUser(int userId) async {
    final db = await dbProvider.db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'income'],
    );

    return result[0]['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpenseByUser(int userId) async {
    final db = await dbProvider.db;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'expense'],
    );

    return result[0]['total'] as double? ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getCategoryExpensesReport(
      int userId) async {
    final db = await dbProvider.db;
    return await db.rawQuery('''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'expense'
      GROUP BY c.id
      ORDER BY total DESC
    ''', [userId]);
  }

  // Update account balance when a transaction is added
  Future<void> updateAccountBalance(int accountId, double amount, String type) async {
    final db = await dbProvider.db;
    
    // Get current balance
    final List<Map<String, dynamic>> accountMaps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
    
    if (accountMaps.isNotEmpty) {
      double currentBalance = accountMaps[0]['balance'] as double;
      
      // Update balance based on transaction type
      double newBalance;
      if (type == 'income') {
        newBalance = currentBalance + amount;
      } else {
        newBalance = currentBalance - amount;
      }
      
      // Update account with new balance
      await db.update(
        'accounts',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [accountId],
      );
    }
  }
}
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/recurring_transaction.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/entities/transaction.dart';
import '../models/transaction.dart' as transaction_model;
import 'transaction_repository.dart';
import 'package:flutter/material.dart';

class RecurringTransactionRepository {
  final dbProvider = DatabaseHelper.instance;
  final transactionRepository = TransactionRepository();

  Future<int> insertRecurringTransaction(RecurringTransaction recurringTransaction) async {
    final db = await dbProvider.db;
    final id = await db.insert('recurring_transactions', recurringTransaction.toMap());
    
    debugPrint('Inserted recurring transaction with ID: $id');
    return id;
  }

  Future<List<RecurringTransaction>> getRecurringTransactionsByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return RecurringTransaction.fromMap(maps[i]);
    });
  }

  Future<RecurringTransaction?> getRecurringTransactionById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurringTransaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRecurringTransaction(RecurringTransaction recurringTransaction) async {
    final db = await dbProvider.db;
    final result = await db.update(
      'recurring_transactions',
      recurringTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [recurringTransaction.id],
    );
    
    debugPrint('Updated recurring transaction with ID: ${recurringTransaction.id}');
    return result;
  }

  Future<int> deleteRecurringTransaction(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Generates a transaction from a recurring transaction template
  Transaction generateTransactionFromTemplate(RecurringTransaction template, DateTime date) {
    return transaction_model.Transaction(
      userId: template.userId,
      accountId: template.accountId ?? 0,
      categoryId: template.categoryId ?? 0,
      amount: template.amount,
      type: template.type,
      description: template.description,
      date: date,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Gets all active recurring transactions that should generate transactions today
  Future<List<RecurringTransaction>> getTodaysRecurringTransactions() async {
    final db = await dbProvider.db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Query for active recurring transactions that:
    // 1. Are active
    // 2. Started before or on today
    // 3. Either have no end date or end date is after or on today
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      where: 'is_active = ? AND start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
      whereArgs: [1, today.toIso8601String(), today.toIso8601String()],
    );

    final recurringTransactions = List.generate(maps.length, (i) {
      return RecurringTransaction.fromMap(maps[i]);
    });

    // Filter for those that actually occur today based on their frequency
    return recurringTransactions.where((rt) {
      switch (rt.frequency) {
        case 'daily':
          return true;
        case 'weekly':
          return rt.dayOfWeek == today.weekday;
        case 'monthly':
          return rt.dayOfMonth == today.day;
        case 'yearly':
          return rt.dayOfMonth == today.day && rt.month == today.month;
        default:
          return false;
      }
    }).toList();
  }

  /// Process all recurring transactions for today and generate corresponding transactions
  Future<void> processTodaysRecurringTransactions() async {
    final recurringTransactions = await getTodaysRecurringTransactions();
    final now = DateTime.now();
    
    for (var rt in recurringTransactions) {
      final transaction = generateTransactionFromTemplate(rt, now);
      await transactionRepository.insertTransaction(transaction);
      debugPrint('Generated transaction from recurring template: ${rt.description}');
    }
  }
}
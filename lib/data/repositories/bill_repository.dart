import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/bill.dart';
import '../../domain/entities/bill.dart';
import 'package:flutter/material.dart';

class BillRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertBill(Bill bill) async {
    final db = await dbProvider.db;
    final id = await db.insert('bills', bill.toMap());
    
    debugPrint('Inserted bill with ID: $id');
    return id;
  }

  Future<List<Bill>> getBillsByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Bill.fromMap(maps[i]);
    });
  }

  Future<Bill?> getBillById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Bill.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBill(Bill bill) async {
    final db = await dbProvider.db;
    final result = await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
    
    debugPrint('Updated bill with ID: ${bill.id}');
    return result;
  }

  Future<int> deleteBill(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get bills that are due within the next 7 days
  Future<List<Bill>> getUpcomingBills(int userId) async {
    final db = await dbProvider.db;
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    // This is a simplified implementation
    // A full implementation would calculate due dates based on frequency
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ? AND is_active = ? AND (due_date >= ? AND due_date <= ?)',
      whereArgs: [userId, 1, now.toIso8601String(), nextWeek.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Bill.fromMap(maps[i]);
    });
  }
}
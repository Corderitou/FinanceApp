import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../../domain/entities/account.dart';

class AccountRepository {
  final dbProvider = DatabaseHelper.instance;

  Future<int> insertAccount(Account account) async {
    final db = await dbProvider.db;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAccountsByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

  Future<Account?> getAccountById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAccount(Account account) async {
    final db = await dbProvider.db;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await dbProvider.db;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    final db = await dbProvider.db;
    await db.update(
      'accounts',
      {'balance': newBalance, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }
}
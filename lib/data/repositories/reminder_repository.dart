import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/reminder.dart';
import '../../domain/entities/reminder.dart';
import '../../services/notification_service.dart';

class ReminderRepository {
  final dbProvider = DatabaseHelper.instance;
  final notificationService = NotificationService();

  Future<int> insertReminder(Reminder reminder) async {
    final db = await dbProvider.db;
    final id = await db.insert('reminders', reminder.toMap());
    
    // Schedule notification for the new reminder if it's active
    if (reminder.isActive) {
      final insertedReminder = reminder.copyWith(id: id);
      await notificationService.scheduleReminderNotification(insertedReminder);
    }
    
    return id;
  }

  Future<List<Reminder>> getRemindersByUser(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ReminderModel.fromMap(maps[i]);
    });
  }

  Future<Reminder?> getReminderById(int id) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ReminderModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await dbProvider.db;
    final result = await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
    
    // Update notification for the reminder
    if (reminder.isActive) {
      await notificationService.scheduleReminderNotification(reminder);
    } else {
      // Cancel notification if reminder is no longer active
      if (reminder.id != null) {
        await notificationService.cancelReminderNotification(reminder.id!);
      }
    }
    
    return result;
  }

  Future<int> deleteReminder(int id) async {
    final db = await dbProvider.db;
    
    // Cancel notification for the reminder
    await notificationService.cancelReminderNotification(id);
    
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Reminder>> getActiveReminders() async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ReminderModel.fromMap(maps[i]);
    });
  }
}
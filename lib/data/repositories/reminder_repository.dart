import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/reminder.dart';
import '../../domain/entities/reminder.dart';
import '../../services/notification_service.dart';
import 'package:flutter/material.dart';

class ReminderRepository {
  final dbProvider = DatabaseHelper.instance;
  final notificationService = NotificationService();

  Future<int> insertReminder(Reminder reminder) async {
    final db = await dbProvider.db;
    final id = await db.insert('reminders', reminder.toMap());
    
    debugPrint('Inserted reminder with ID: $id');
    
    // Schedule notification for the new reminder if it's active
    if (reminder.isActive) {
      final insertedReminder = reminder.copyWith(id: id);
      debugPrint('Scheduling notification for reminder: ${insertedReminder.name}');
      
      // Request exact alarm permission before scheduling
      await notificationService.requestExactAlarmsPermission();
      
      await notificationService.scheduleReminderNotification(insertedReminder);
      debugPrint('Scheduled notification for reminder ID: $id');
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
    
    debugPrint('Updated reminder with ID: ${reminder.id}');
    
    // Update notification for the reminder
    if (reminder.isActive) {
      debugPrint('Updating notification for reminder: ${reminder.name}');
      
      // Request exact alarm permission before scheduling
      await notificationService.requestExactAlarmsPermission();
      
      await notificationService.scheduleReminderNotification(reminder);
      debugPrint('Updated notification for reminder ID: ${reminder.id}');
    } else {
      // Cancel notification if reminder is no longer active
      if (reminder.id != null) {
        debugPrint('Cancelling notification for reminder ID: ${reminder.id}');
        await notificationService.cancelReminderNotification(reminder.id!);
      }
    }
    
    return result;
  }

  Future<int> deleteReminder(int id) async {
    final db = await dbProvider.db;
    
    // Cancel notification for the reminder
    debugPrint('Deleting reminder with ID: $id');
    await notificationService.cancelReminderNotification(id);
    debugPrint('Cancelled notification for reminder ID: $id');
    
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
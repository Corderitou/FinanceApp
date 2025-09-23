import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/entities/recurring_transaction.dart';

extension RecurringTransactionNotification on FlutterLocalNotificationsPlugin {
  /// Schedule a notification for a recurring transaction
  Future<void> scheduleRecurringTransactionNotification(RecurringTransaction recurringTransaction) async {
    try {
      // Create notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'recurring_transaction_channel_id',
        'Recurring Transactions',
        channelDescription: 'Notifications for recurring transactions',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Schedule based on frequency
      switch (recurringTransaction.frequency) {
        case 'daily':
          final scheduledDate = _nextInstanceOfTime(recurringTransaction);
          await zonedSchedule(
            recurringTransaction.id ?? 0,
            'Recurring Transaction Due',
            recurringTransaction.description ?? 'A recurring transaction is due today',
            scheduledDate,
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'recurring_transaction_${recurringTransaction.id}',
          );
          break;
        case 'weekly':
          if (recurringTransaction.dayOfWeek != null) {
            final scheduledDate = _nextInstanceOfWeeklyTime(recurringTransaction);
            await zonedSchedule(
              recurringTransaction.id ?? 0,
              'Recurring Transaction Due',
              recurringTransaction.description ?? 'A recurring transaction is due today',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
              payload: 'recurring_transaction_${recurringTransaction.id}',
            );
          }
          break;
        case 'monthly':
          if (recurringTransaction.dayOfMonth != null) {
            final scheduledDate = _nextInstanceOfMonthlyTime(recurringTransaction);
            await zonedSchedule(
              recurringTransaction.id ?? 0,
              'Recurring Transaction Due',
              recurringTransaction.description ?? 'A recurring transaction is due today',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
              payload: 'recurring_transaction_${recurringTransaction.id}',
            );
          }
          break;
        case 'yearly':
          if (recurringTransaction.dayOfMonth != null && recurringTransaction.month != null) {
            final scheduledDate = _nextInstanceOfYearlyTime(recurringTransaction);
            await zonedSchedule(
              recurringTransaction.id ?? 0,
              'Recurring Transaction Due',
              recurringTransaction.description ?? 'A recurring transaction is due today',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dateAndTime,
              payload: 'recurring_transaction_${recurringTransaction.id}',
            );
          }
          break;
      }
    } catch (e) {
      // Handle error
      print('Error scheduling recurring transaction notification: $e');
    }
  }

  /// Cancel a recurring transaction notification
  Future<void> cancelRecurringTransactionNotification(int transactionId) async {
    await cancel(transactionId);
  }

  // Get the next instance of a specific time today or tomorrow
  tz.TZDateTime _nextInstanceOfTime(RecurringTransaction rt) {
    final now = tz.TZDateTime.now(tz.local);
    // Parse time from the recurring transaction
    final timeParts = rt.startDate.toString().split(' ')[1].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // If it's already past the specified time today, schedule for tomorrow
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Get the next instance of a weekly time
  tz.TZDateTime _nextInstanceOfWeeklyTime(RecurringTransaction rt) {
    final now = tz.TZDateTime.now(tz.local);
    // Parse time from the recurring transaction
    final timeParts = rt.startDate.toString().split(' ')[1].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // Adjust to the correct day of the week
    final int currentDayOfWeek = scheduledDate.weekday;
    final int daysUntilTarget = (rt.dayOfWeek! - currentDayOfWeek + 7) % 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));
    
    // If it's the target day and the time has already passed, schedule for next week
    if (daysUntilTarget == 0 && (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  // Get the next instance of a monthly time
  tz.TZDateTime _nextInstanceOfMonthlyTime(RecurringTransaction rt) {
    final now = tz.TZDateTime.now(tz.local);
    // Parse time from the recurring transaction
    final timeParts = rt.startDate.toString().split(' ')[1].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      rt.dayOfMonth!,
      hour,
      minute,
    );
    
    // If the day doesn't exist in this month (e.g., Feb 31), move to next month
    if (scheduledDate.month != now.month) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        rt.dayOfMonth!,
        hour,
        minute,
      );
    }
    
    // If it's already past the specified time today, schedule for next month
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      // Handle month overflow
      int nextYear = scheduledDate.year;
      int nextMonth = scheduledDate.month + 1;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      
      scheduledDate = tz.TZDateTime(
        tz.local,
        nextYear,
        nextMonth,
        rt.dayOfMonth!,
        hour,
        minute,
      );
    }
    
    return scheduledDate;
  }

  // Get the next instance of a yearly time
  tz.TZDateTime _nextInstanceOfYearlyTime(RecurringTransaction rt) {
    final now = tz.TZDateTime.now(tz.local);
    // Parse time from the recurring transaction
    final timeParts = rt.startDate.toString().split(' ')[1].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      rt.month!,
      rt.dayOfMonth!,
      hour,
      minute,
    );
    
    // If it's already past the specified time this year, schedule for next year
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        rt.month!,
        rt.dayOfMonth!,
        hour,
        minute,
      );
    }
    
    return scheduledDate;
  }
}
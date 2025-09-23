import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/entities/bill.dart';

extension BillNotification on FlutterLocalNotificationsPlugin {
  /// Schedule a notification for a bill due date
  Future<void> scheduleBillNotification(Bill bill) async {
    // Only schedule if bill has a due date or day of month
    if (bill.dueDate == null && bill.dayOfMonth == null) return;
    
    try {
      // Create notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'bill_reminder_channel_id',
        'Bill Reminders',
        channelDescription: 'Notifications for upcoming bill due dates',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Calculate next due date
      final scheduledDate = _calculateNextDueDate(bill);
      
      if (scheduledDate != null) {
        await zonedSchedule(
          bill.id ?? 0,
          'Bill Due: ${bill.name}',
          'Your bill "${bill.name}" is due today${bill.amount != null ? ' (\$${bill.amount!.toStringAsFixed(2)})' : ''}',
          scheduledDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: _getDateTimeComponents(bill),
          payload: 'bill_${bill.id}',
        );
      }
    } catch (e) {
      // Handle error
      print('Error scheduling bill notification: $e');
    }
  }

  /// Cancel a bill notification
  Future<void> cancelBillNotification(int billId) async {
    await cancel(billId);
  }

  /// Calculate the next due date for a bill
  tz.TZDateTime? _calculateNextDueDate(Bill bill) {
    final now = tz.TZDateTime.now(tz.local);
    
    if (bill.dueDate != null) {
      // If bill has a specific due date
      final dueDate = tz.TZDateTime.from(bill.dueDate!, tz.local);
      
      // If due date is in the future, use it
      if (dueDate.isAfter(now)) {
        return dueDate;
      }
      
      // If it's a one-time bill and due date is in the past, don't schedule
      if (bill.frequency == 'once') {
        return null;
      }
      
      // For recurring bills, calculate next occurrence
      return _calculateNextRecurringDueDate(bill, dueDate);
    } else if (bill.dayOfMonth != null) {
      // If bill has a day of month
      return _calculateNextDueDateByDay(bill, now);
    }
    
    return null;
  }

  /// Calculate next recurring due date
  tz.TZDateTime _calculateNextRecurringDueDate(Bill bill, tz.TZDateTime lastDueDate) {
    final now = tz.TZDateTime.now(tz.local);
    
    switch (bill.frequency) {
      case 'monthly':
        // Add one month
        var nextYear = lastDueDate.year;
        var nextMonth = lastDueDate.month + 1;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        
        // Handle day overflow (e.g., Jan 31 -> Feb 31 doesn't exist)
        var nextDay = lastDueDate.day;
        if (nextMonth == 2 && nextDay > 28) {
          nextDay = 28;
        } else if ([4, 6, 9, 11].contains(nextMonth) && nextDay > 30) {
          nextDay = 30;
        }
        
        var nextDate = tz.TZDateTime(tz.local, nextYear, nextMonth, nextDay, 
            lastDueDate.hour, lastDueDate.minute);
        
        // If calculated date is still in the past, move to next month
        while (nextDate.isBefore(now)) {
          nextYear = nextDate.year;
          nextMonth = nextDate.month + 1;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          
          // Handle day overflow again
          nextDay = lastDueDate.day;
          if (nextMonth == 2 && nextDay > 28) {
            nextDay = 28;
          } else if ([4, 6, 9, 11].contains(nextMonth) && nextDay > 30) {
            nextDay = 30;
          }
          
          nextDate = tz.TZDateTime(tz.local, nextYear, nextMonth, nextDay,
              lastDueDate.hour, lastDueDate.minute);
        }
        
        return nextDate;
        
      case 'quarterly':
        // Add 3 months
        var nextYear = lastDueDate.year;
        var nextMonth = lastDueDate.month + 3;
        if (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        
        // Handle day overflow
        var nextDay = lastDueDate.day;
        if (nextMonth == 2 && nextDay > 28) {
          nextDay = 28;
        } else if ([4, 6, 9, 11].contains(nextMonth) && nextDay > 30) {
          nextDay = 30;
        }
        
        return tz.TZDateTime(tz.local, nextYear, nextMonth, nextDay,
            lastDueDate.hour, lastDueDate.minute);
        
      case 'yearly':
        // Add one year
        return tz.TZDateTime(tz.local, lastDueDate.year + 1, lastDueDate.month, lastDueDate.day,
            lastDueDate.hour, lastDueDate.minute);
        
      default:
        return lastDueDate.add(const Duration(days: 30));
    }
  }

  /// Calculate next due date by day of month
  tz.TZDateTime _calculateNextDueDateByDay(Bill bill, tz.TZDateTime now) {
    final dayOfMonth = bill.dayOfMonth!;
    
    // Create date for this month
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, dayOfMonth, 9, 0);
    
    // If this month's date is in the past, use next month
    if (scheduledDate.isBefore(now)) {
      var nextYear = now.year;
      var nextMonth = now.month + 1;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      
      // Handle day overflow
      var nextDay = dayOfMonth;
      if (nextMonth == 2 && nextDay > 28) {
        nextDay = 28;
      } else if ([4, 6, 9, 11].contains(nextMonth) && nextDay > 30) {
        nextDay = 30;
      }
      
      scheduledDate = tz.TZDateTime(tz.local, nextYear, nextMonth, nextDay, 9, 0);
    }
    
    return scheduledDate;
  }

  /// Get DateTimeComponents based on bill frequency
  DateTimeComponents _getDateTimeComponents(Bill bill) {
    if (bill.dueDate != null) {
      // For specific dates, match based on frequency
      switch (bill.frequency) {
        case 'once':
          return DateTimeComponents.dateAndTime;
        case 'yearly':
          return DateTimeComponents.dateAndTime;
        case 'monthly':
          return DateTimeComponents.dayOfMonthAndTime;
        case 'quarterly':
          return DateTimeComponents.dayOfMonthAndTime;
        default:
          return DateTimeComponents.time;
      }
    } else if (bill.dayOfMonth != null) {
      // For day of month, match day and time
      return DateTimeComponents.dayOfMonthAndTime;
    }
    
    return DateTimeComponents.time;
  }
}
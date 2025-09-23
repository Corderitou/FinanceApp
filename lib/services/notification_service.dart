import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_handler.dart';
import '../domain/entities/reminder.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Set local location to device's timezone
    tz.setLocalLocation(tz.local);

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings for both platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin with specific settings to avoid serialization issues
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap
        if (details.payload != null) {
          _handleNotificationTap(details.payload!);
        }
      },
    );
    
    // Request notification permissions
    await requestNotificationPermissions();
  }

  // Request notification permissions (especially important for Android 13+ and iOS)
  Future<bool> requestNotificationPermissions() async {
    // For Android 13+ request POST_NOTIFICATIONS permission
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        if (granted != true) {
          debugPrint('Permiso de notificaciones denegado');
          return false;
        }
      } catch (e) {
        debugPrint('Error solicitando permiso de notificaciones: $e');
        return false;
      }
    }
    
    // For iOS, permissions are requested during initialization
    // but we can also request them explicitly:
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final bool? iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return iosGranted ?? false;
    }
    
    return true;
  }

  // Request exact alarm permissions (for Android 12+)
  Future<bool?> requestExactAlarmsPermission() async {
    try {
      // For Android 12+, we need to request the exact alarm permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        // Request the permission
        final bool? granted = await androidImplementation.requestExactAlarmsPermission();
        debugPrint('Requested exact alarms permission, granted: $granted');
        return granted;
      }
      
      // For other platforms or if implementation is not available, return null
      debugPrint('Android implementation not available for exact alarms');
      return null;
    } catch (e) {
      // If there's an error requesting the permission, log it and return null
      debugPrint('Error requesting exact alarms permission: $e');
      return null;
    }
  }

  // Check if notifications are enabled
  Future<bool> _checkNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      } catch (e) {
        debugPrint('Error verificando permisos de notificaciones: $e');
        return false;
      }
    }
    
    return true; // Assume true for other platforms
  }

  // Schedule daily notification at 19:00 (7:00 PM)
  Future<void> scheduleDailyNotification(int userId) async {
    // Check permissions before scheduling
    final bool hasPermission = await _checkNotificationPermission();
    if (!hasPermission) {
      debugPrint('No se pueden programar notificaciones sin permisos');
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_work_reminder_channel_id',
      'Recordatorio Diario de Trabajo',
      channelDescription: 'Notificación diaria para recordar registrar el lugar de trabajo',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Schedule the notification to appear daily at 19:00
    final scheduledDate = _nextInstanceOfSevenPM();
    debugPrint('Scheduling daily notification for: ${scheduledDate.toIso8601String()}');
    debugPrint('Current time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
    debugPrint('Time difference: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inSeconds} seconds');
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      '¿Dónde trabajaste hoy?',
      'Toca para registrar tu lugar de trabajo',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'work_location_reminder_$userId', // Payload to identify the notification
    );
  }

  // Cancel the daily notification
  Future<void> cancelDailyNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  // Schedule reminder notification
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    try {
      debugPrint('Scheduling reminder notification for: ${reminder.name} (ID: ${reminder.id})');
      debugPrint('Reminder details - Frequency: ${reminder.frequency}, Time: ${reminder.time}');
      
      // Check permissions before scheduling
      final bool hasPermission = await _checkNotificationPermission();
      if (!hasPermission) {
        debugPrint('No se pueden programar notificaciones sin permisos');
        return;
      }
      
      // Check exact alarm permission
      final bool? exactAlarmGranted = await requestExactAlarmsPermission();
      if (exactAlarmGranted == false) {
        debugPrint('Permiso de alarmas exactas denegado');
        return;
      }
      
      // Create notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminder_channel_id',
        'Recordatorios',
        channelDescription: 'Notificaciones de recordatorios',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Parse the time from the reminder
      final timeParts = reminder.time.split(':');
      if (timeParts.length != 2) {
        debugPrint('Invalid time format: ${reminder.time}');
        return;
      }
      
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) {
        debugPrint('Invalid hour or minute: ${timeParts[0]}:${timeParts[1]}');
        return;
      }

      debugPrint('Parsed time - Hour: $hour, Minute: $minute');

      // Schedule based on frequency
      switch (reminder.frequency) {
        case 'daily':
          debugPrint('Scheduling daily notification');
          final scheduledDate = _nextInstanceOfTime(hour, minute);
          debugPrint('Scheduling notification for: ${scheduledDate.toIso8601String()}');
          debugPrint('Current time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
          debugPrint('Time difference: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inSeconds} seconds');
          
          await flutterLocalNotificationsPlugin.zonedSchedule(
            reminder.id ?? 0, // Use reminder ID as notification ID
            reminder.name,
            reminder.description ?? 'Tienes un recordatorio programado',
            scheduledDate,
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: 'reminder_${reminder.id}', // Payload to identify the notification
          );
          debugPrint('Scheduled daily notification for reminder ID: ${reminder.id}');
          break;
        case 'weekly':
          if (reminder.dayOfWeek != null) {
            debugPrint('Scheduling weekly notification for day: ${reminder.dayOfWeek}');
            final scheduledDate = _nextInstanceOfWeeklyTime(hour, minute, reminder.dayOfWeek!);
            debugPrint('Scheduling notification for: ${scheduledDate.toIso8601String()}');
            debugPrint('Current time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
            debugPrint('Time difference: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inSeconds} seconds');
            
            await flutterLocalNotificationsPlugin.zonedSchedule(
              reminder.id ?? 0,
              reminder.name,
              reminder.description ?? 'Tienes un recordatorio programado',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
              payload: 'reminder_${reminder.id}',
            );
            debugPrint('Scheduled weekly notification for reminder ID: ${reminder.id}');
          } else {
            debugPrint('Weekly reminder missing day of week');
          }
          break;
        case 'monthly':
          if (reminder.dayOfMonth != null) {
            debugPrint('Scheduling monthly notification for day: ${reminder.dayOfMonth}');
            final scheduledDate = _nextInstanceOfMonthlyTime(hour, minute, reminder.dayOfMonth!);
            debugPrint('Scheduling notification for: ${scheduledDate.toIso8601String()}');
            debugPrint('Current time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
            debugPrint('Time difference: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inSeconds} seconds');
            
            await flutterLocalNotificationsPlugin.zonedSchedule(
              reminder.id ?? 0,
              reminder.name,
              reminder.description ?? 'Tienes un recordatorio programado',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
              payload: 'reminder_${reminder.id}',
            );
            debugPrint('Scheduled monthly notification for reminder ID: ${reminder.id}');
          } else {
            debugPrint('Monthly reminder missing day of month');
          }
          break;
        case 'yearly':
          if (reminder.dayOfMonth != null && reminder.month != null) {
            debugPrint('Scheduling yearly notification for day: ${reminder.dayOfMonth}, month: ${reminder.month}');
            final scheduledDate = _nextInstanceOfYearlyTime(hour, minute, reminder.dayOfMonth!, reminder.month!);
            debugPrint('Scheduling notification for: ${scheduledDate.toIso8601String()}');
            debugPrint('Current time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
            debugPrint('Time difference: ${scheduledDate.difference(tz.TZDateTime.now(tz.local)).inSeconds} seconds');
            
            await flutterLocalNotificationsPlugin.zonedSchedule(
              reminder.id ?? 0,
              reminder.name,
              reminder.description ?? 'Tienes un recordatorio programado',
              scheduledDate,
              platformChannelSpecifics,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.dateAndTime,
              payload: 'reminder_${reminder.id}',
            );
            debugPrint('Scheduled yearly notification for reminder ID: ${reminder.id}');
          } else {
            debugPrint('Yearly reminder missing day of month or month');
          }
          break;
        default:
          debugPrint('Unknown frequency: ${reminder.frequency}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error programando notificación de recordatorio: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Cancel a reminder notification
  Future<void> cancelReminderNotification(int reminderId) async {
    await flutterLocalNotificationsPlugin.cancel(reminderId);
  }

  // Get the next instance of a specific time today or tomorrow
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
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
  tz.TZDateTime _nextInstanceOfWeeklyTime(int hour, int minute, int dayOfWeek) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // dayOfWeek in DateTime is 1=Monday to 7=Sunday
    // but in our app it's 1=Monday to 7=Sunday, so no conversion needed
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
    final int daysUntilTarget = (dayOfWeek - currentDayOfWeek + 7) % 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));
    
    // If it's the target day and the time has already passed, schedule for next week
    if (daysUntilTarget == 0 && (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  // Get the next instance of a monthly time
  tz.TZDateTime _nextInstanceOfMonthlyTime(int hour, int minute, int dayOfMonth) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dayOfMonth,
      hour,
      minute,
    );
    
    // If the day doesn't exist in this month (e.g., Feb 31), move to next month
    if (scheduledDate.month != now.month) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        dayOfMonth,
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
        dayOfMonth,
        hour,
        minute,
      );
    }
    
    return scheduledDate;
  }

  // Get the next instance of a yearly time
  tz.TZDateTime _nextInstanceOfYearlyTime(int hour, int minute, int dayOfMonth, int month) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      month,
      dayOfMonth,
      hour,
      minute,
    );
    
    // If it's already past the specified time this year, schedule for next year
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        month,
        dayOfMonth,
        hour,
        minute,
      );
    }
    
    return scheduledDate;
  }

  // Get the next instance of 19:00 today or tomorrow
  tz.TZDateTime _nextInstanceOfSevenPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19, // 19:00 hours
      0, // 0 minutes
    );
    
    // If it's already past 19:00 today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Handle notification tap
  void _handleNotificationTap(String payload) {
    if (payload.startsWith('work_location_reminder_')) {
      // Extract user ID from payload (format: work_location_reminder_{userId})
      final userId = int.tryParse(payload.split('_').last) ?? 1;
      NotificationHandler().handleWorkLocationNotificationTap(userId);
    } else if (payload.startsWith('reminder_')) {
      // Extract reminder ID from payload (format: reminder_{reminderId})
      final reminderId = int.tryParse(payload.split('_').last);
      if (reminderId != null) {
        // TODO: Implement reminder notification tap handling
        debugPrint('Reminder notification tapped: $reminderId');
      }
    }
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'immediate_notification_channel_id',
      'Notificación Inmediata',
      channelDescription: 'Notificación de prueba',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1, // Notification ID
      'Notificación de prueba',
      'Esta es una notificación inmediata',
      platformChannelSpecifics,
      payload: 'test_notification',
    );
  }
}
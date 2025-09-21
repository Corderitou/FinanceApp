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
    
    // Set to UTC as default timezone
    tz.setLocalLocation(tz.getLocation('UTC'));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle notification tap when app is in foreground on iOS
      },
    );

    // Initialization settings for both platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap
        if (details.payload != null) {
          _handleNotificationTap(details.payload!);
        }
      },
    );
  }

  // Request notification permissions (especially important for Android 13+ and iOS)
  Future<bool> requestNotificationPermissions() async {
    // For iOS, permissions are requested during initialization
    // but we can also request them explicitly:
    final bool iosGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? true;
    
    // On Android, permissions are typically granted automatically
    // unless the user has manually disabled them
    final bool androidGranted = true;
    
    return androidGranted && iosGranted;
  }

  // Request exact alarm permissions (for Android 12+)
  Future<bool> requestExactAlarmsPermission() async {
    // On Android, this permission may need to be requested manually by the user
    // in the app settings for Android 12+. For now, we'll just return true.
    return true;
  }

  // Schedule daily notification at 19:00 (7:00 PM)
  Future<void> scheduleDailyNotification(int userId) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_work_reminder_channel_id',
      'Recordatorio Diario de Trabajo',
      channelDescription: 'Notificación diaria para recordar registrar el lugar de trabajo',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Schedule the notification to appear daily at 19:00
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      '¿Dónde trabajaste hoy?',
      'Toca para registrar tu lugar de trabajo',
      _nextInstanceOfSevenPM(),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
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
    // Create notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel_id',
      'Recordatorios',
      channelDescription: 'Notificaciones de recordatorios',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Parse the time from the reminder
    final timeParts = reminder.time.split(':');
    if (timeParts.length != 2) return;
    
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return;

    // Schedule based on frequency
    switch (reminder.frequency) {
      case 'daily':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          reminder.id ?? 0, // Use reminder ID as notification ID
          reminder.name,
          reminder.description ?? 'Tienes un recordatorio programado',
          _nextInstanceOfTime(hour, minute),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'reminder_${reminder.id}', // Payload to identify the notification
        );
        break;
      case 'weekly':
        if (reminder.dayOfWeek != null) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            reminder.id ?? 0,
            reminder.name,
            reminder.description ?? 'Tienes un recordatorio programado',
            _nextInstanceOfWeeklyTime(hour, minute, reminder.dayOfWeek!),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'reminder_${reminder.id}',
          );
        }
        break;
      case 'monthly':
        if (reminder.dayOfMonth != null) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            reminder.id ?? 0,
            reminder.name,
            reminder.description ?? 'Tienes un recordatorio programado',
            _nextInstanceOfMonthlyTime(hour, minute, reminder.dayOfMonth!),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
            payload: 'reminder_${reminder.id}',
          );
        }
        break;
      case 'yearly':
        if (reminder.dayOfMonth != null && reminder.month != null) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            reminder.id ?? 0,
            reminder.name,
            reminder.description ?? 'Tienes un recordatorio programado',
            _nextInstanceOfYearlyTime(hour, minute, reminder.dayOfMonth!, reminder.month!),
            platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: 'reminder_${reminder.id}',
          );
        }
        break;
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
    if (scheduledDate.isBefore(now)) {
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
    
    // If it's already past the specified time today and it's the target day, schedule for next week
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
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
    if (scheduledDate.isBefore(now)) {
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
    if (scheduledDate.isBefore(now)) {
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
        _handleReminderNotificationTap(reminderId);
      }
    }
  }

  // Handle reminder notification tap
  void _handleReminderNotificationTap(int reminderId) {
    // TODO: Implement reminder notification tap handling
    debugPrint('Reminder notification tapped: $reminderId');
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_handler.dart';

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
      sound: RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        sound: 'notification.caf',
      ),
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
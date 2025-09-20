import 'package:flutter/material.dart';
import '../presentation/screens/work_location/work_location_form_screen.dart';

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  // This will be set by the main app when it's initialized
  Function(int userId)? onWorkLocationNotificationTap;

  // Handle work location notification tap
  void handleWorkLocationNotificationTap(int userId) {
    if (onWorkLocationNotificationTap != null) {
      onWorkLocationNotificationTap!(userId);
    } else {
      debugPrint('No handler set for work location notification tap');
    }
  }
}
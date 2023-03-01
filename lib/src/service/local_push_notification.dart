import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalPushNotificationsManager {
  LocalPushNotificationsManager._();
  factory LocalPushNotificationsManager() => _instance;
  static final LocalPushNotificationsManager _instance =
      LocalPushNotificationsManager._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  initialize() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: null, iOS: initializationSettingsIOS, macOS: null);

    tz.initializeTimeZones();

    var result = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification);

    _initialized = result ?? false;
  }

  Future onDidReceiveLocalNotification(NotificationResponse response) async {
    log(response.toString());
  }

  Future createScheduleNoti(
    int id,
    String title,
    String description,
    DateTime scheduledDateTime,
  ) async {
    if (!_initialized) await initialize();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        description,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails("CHANNEL_ID", "CHANNEL_NAME",
                channelDescription: "CHANNEL_DESCRIPTION")),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    log("Successfully");
  }
}

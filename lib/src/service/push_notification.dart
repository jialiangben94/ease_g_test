import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  PushNotificationsManager._();
  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  bool _initialized = false;

  Future<String?> getToken() async {
    if (!_initialized) {
      // For iOS request permission first.
      await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true);
      _initialized = true;
    }

    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.getAPNSToken();

    return token;
  }
}

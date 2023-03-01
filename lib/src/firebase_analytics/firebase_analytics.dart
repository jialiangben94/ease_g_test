import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

Future<void> analyticsSetCurrentScreen(
    String screenName, String screenClassOverride) async {
  await analytics.setCurrentScreen(
      screenName: screenName, screenClassOverride: screenClassOverride);
}

Future<void> analyticsSendEvent(
    String eventName, Map<String, dynamic>? parameters) async {
  await analytics.logEvent(name: eventName, parameters: parameters);
}

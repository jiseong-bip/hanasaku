import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hanasaku/main.dart';
import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocalNotification {
  LocalNotification._();
  static int badgeNumber = 0;

  static initialize() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings("app_icon");

    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationResponse);
  }

  static void requestPermission() {
    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> postNotification(String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      "channel id",
      "post notification",
      channelDescription: "This channel displays post notification",
      importance: Importance.max,
      priority: Priority.max,
      showWhen: false,
      channelShowBadge: true,
      playSound: false,
      number: badgeNumber,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        badgeNumber: ++badgeNumber,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      "HANASAKU",
      body,
      platformChannelSpecifics,
      payload: "post",
    );
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    //! Payload(전송 데이터)를 Stream에 추가합니다.
    final String payload = notificationResponse.payload ?? "";
    if (notificationResponse.payload != null ||
        notificationResponse.payload!.isNotEmpty) {
      streamController.add(payload);
    }
  }

  @pragma('vm:entry-point')
  static void onBackgroundNotificationResponse(
      NotificationResponse notificationResponse) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();
    //! 앱이 Notification을 통해서 열린 경우라면 Payload(전송 데이터)를 Stream에 추가합니다.
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      String payload =
          notificationAppLaunchDetails!.notificationResponse?.payload ?? "";

      streamController.add(payload);
    }
  }

  static void resetBadge() async {
    badgeNumber = 0;
    FlutterAppBadger.removeBadge();
  }
}

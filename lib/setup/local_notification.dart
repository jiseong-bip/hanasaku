import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hanasaku/chat/chat_room_screen.dart';
import 'package:hanasaku/home/screens/notify_screen.dart';
import 'dart:io' show Platform;
import 'package:hanasaku/main.dart';
import 'package:hanasaku/setup/provider_model.dart';

/// Firebase Background Messaging 핸들러
Future<void> fbMsgBackgroundHandler(RemoteMessage message) async {
  print("[FCM - Background] MESSAGE : $message");
  if (message.data['type'] != 'chat') {
    final listResultModel = ListResultService.instance.listResultModel;

    Map<String, dynamic> notificationData = {
      'message': message.notification?.body,
      'data': message.data
    };

    listResultModel.updateList(notificationData);
  }
}

/// Firebase Foreground Messaging 핸들러
Future<void> fbMsgForegroundHandler(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    AndroidNotificationChannel? channel) async {
  if (message.data['type'] != 'chat') {
    final listResultModel = ListResultService.instance.listResultModel;

    Map<String, dynamic> notificationData = {
      'message': message.notification?.body,
      'data': message.data
    };

    listResultModel.updateList(notificationData);
  }
  if (message.notification != null) {
    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              badgeNumber: 1,
            )));
  }
}

/// FCM 메시지 클릭 이벤트 정의
Future<void> setupInteractedMessage(FirebaseMessaging fbMsg) async {
  RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
  // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
  if (initialMessage != null) clickMessageEvent(initialMessage);
  // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
  FirebaseMessaging.onMessageOpenedApp.listen(clickMessageEvent);
}

void clickMessageEvent(RemoteMessage message) {
  if (message.data['type'] == 'chat') {
    MyApp.navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) {
          return ChatRoom(
            roomId: int.parse(message.data['roomId']),
            userName: message.data['userName'],
            userId: int.parse(message.data['userId']),
          );
        },
      ),
    );
  } else {
    MyApp.navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) {
          return const NotifyScreen();
        },
      ),
    );
  }
}

class LocalNotification {
  LocalNotification._();

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static initialize() async {
    FirebaseMessaging fbMsg = FirebaseMessaging.instance;
    // 플랫폼 확인후 권한요청 및 Flutter Local Notification Plugin 설정
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    AndroidNotificationChannel? androidNotificationChannel;
    if (Platform.isAndroid) {
      //Android 8 (API 26) 이상부터는 채널설정이 필수.
      androidNotificationChannel = const AndroidNotificationChannel(
        'important_channel', // id
        'Important_Notifications', // name
        description: '중요도가 높은 알림을 위한 채널.',
        // description
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
    }
    //Background Handling 백그라운드 메세지 핸들링
    FirebaseMessaging.onBackgroundMessage(fbMsgBackgroundHandler);
    //Foreground Handling 포어그라운드 메세지 핸들링
    FirebaseMessaging.onMessage.listen((message) {
      fbMsgForegroundHandler(
          message, flutterLocalNotificationsPlugin, androidNotificationChannel);
    });
    //Message Click Event Implement
    await setupInteractedMessage(fbMsg);
  }

  static void requestPermission() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      // IOS background 권한 체킹 , 요청
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } else {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    }
  }

  static void resetBadge() async {
    FlutterAppBadger.removeBadge();
  }
}

class ListResultService {
  static final ListResultService _instance = ListResultService._internal();

  static ListResultService get instance => _instance;

  ListResultService._internal();

  final listResultModel = ListResultModel();
}

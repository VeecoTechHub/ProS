import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

final userID = FirebaseAuth.instance.currentUser?.uid.obs;

class FirebaseMessagingHandler {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static init({
    required Function(String?) getToken,
  }) async {
    // request permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint('FCM --> authorized');
        break;
      case AuthorizationStatus.denied:
        debugPrint('FCM --> denied');
        break;
      case AuthorizationStatus.notDetermined:
        debugPrint('FCM --> notDetermined');
        break;
      case AuthorizationStatus.provisional:
        debugPrint('FCM --> provisional');
        break;
    }
    // Get the APNs token
    String? apnsToken = await messaging.getAPNSToken();
    log(name: "APNs token: ", "$apnsToken");
    // Get the FCM token
    await FirebaseMessaging.instance.getToken().then((token) async {
      log(name: "FCM: ", "$token");
      getToken(token);
    });

    // Customize Notification
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(),
      ),
    );

    var androidNotificationChannel = const AndroidNotificationChannel(
      "Push Notification",
      "Push Notification",
    );
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidNotificationChannel);
  }

  static Future<String> downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static showLocalNotification({
    required String title,
    required String body,
    required String imageUrl,
  }) async {
    final String bigPicturePath = await downloadAndSaveFile(imageUrl, 'bigPicture.jpg');
    final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(attachments: <DarwinNotificationAttachment>[
      DarwinNotificationAttachment(
        bigPicturePath,
      )
    ]);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'local_channel_id',
          'Local Notifications',
          importance: Importance.high,
          styleInformation: imageUrl.isNotEmpty
              ? BigPictureStyleInformation(
                  hideExpandedLargeIcon: true,
                  FilePathAndroidBitmap(imageUrl),
                  contentTitle: title,
                  summaryText: body,
                  htmlFormatContentTitle: true,
                  htmlFormatSummaryText: true,
                )
              : BigTextStyleInformation(
                  body,
                  htmlFormatBigText: true,
                  contentTitle: title,
                  htmlFormatContentTitle: true,
                ),
          priority: Priority.high,
          playSound: true,
          // sound: const RawResourceAndroidNotificationSound('notification_sound'),
        ),
        iOS: darwinNotificationDetails,
      ),
      payload: 'Test payload',
    );
  }
}

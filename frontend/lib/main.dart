import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/change_password.dart';
import 'package:frontend/pages/chat.dart';
import 'package:frontend/pages/entrance.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/register.dart';
import 'package:frontend/pages/chats.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

String? token;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(
    BaseOptions(
      baseUrl: defaultTargetPlatform != TargetPlatform.android
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000',
    ),
  );
  final storage = FlutterSecureStorage();
  token = await storage.read(key: 'token');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final tokenFire = await FirebaseMessaging.instance.getToken();
  print('fire $tokenFire');
  FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
  if (token != null) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  runApp(
    Provider(
      create: (context) => dio,
      child: MaterialApp(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              if (token == null) {
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Entrance(),
                );
              } else {
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => Profile(),
                  transitionDuration: Duration.zero,
                );
              }
            case '/entrance':
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => Entrance(),
                transitionDuration: Duration.zero,
              );
            case '/register':
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => Register(),
                transitionDuration: Duration.zero,
              );
            case '/profile':
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => Profile(),
                transitionDuration: Duration.zero,
              );
            case '/change_password':
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ChangePassword(),
                transitionDuration: Duration.zero,
              );
            case '/chats':
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => Chats(),
                transitionDuration: Duration.zero,
              );
            case '/chat':
              final args = settings.arguments as Map;
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => Chat(userId: args['userId']),
                transitionDuration: Duration.zero,
              );
          }
          return null;
        },
      ),
    ),
  );
}

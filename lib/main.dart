import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'providers/auth_methods.dart';
import 'providers/user_provider.dart';
import 'responsive/mobile_screen_layout.dart';
import 'responsive/repsonsive_layout_screen.dart';
import 'responsive/web_screen_layout.dart';
import 'screens/login/login_screen_phone.dart';
import 'utils/logger.dart';
import 'utils/styles/colors.dart';
import 'utils/styles/neon_background.dart';

// Initialize notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _setupNotificationListener() async {
  const MethodChannel _channel = MethodChannel("notifications_channel");
  final authMethods = AuthMethods();
  _channel.setMethodCallHandler((call) async {
    if (call.method == "validate_action") {
      authMethods.updateIsActiveStatus(true);
    } else if (call.method == "cancel_action") {
      authMethods.updateIsActiveStatus(false);
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message}");
  final String? eventType = message.data['event'];
  if (eventType == "daily_ask_turn") {
    print("Daily ask turn event reçu");
    final MethodChannel _channel = const MethodChannel("notifications_channel");
    await _channel.invokeMethod("scheduleNotification");
  }
  if (eventType == "daily_ask_turn_already") {
    print("Daily ask turn event AGAIN reçu");
    final MethodChannel _channel = const MethodChannel("notifications_channel");
    await _channel.invokeMethod("scheduleNotification");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Request notification permissions and configure Firebase Messaging
  await _initializeFirebaseMessaging();

  runApp(const CFQ());
}

Future<void> _initializeFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  initSubscribeToTopic();

  _setupNotificationListener();
}

void initSubscribeToTopic() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  if (Platform.isIOS) {
    String? apnsToken = await _firebaseMessaging.getAPNSToken();
    if (apnsToken != null) {
      await _firebaseMessaging.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic("daily_ask_turn");
      await FirebaseMessaging.instance
          .subscribeToTopic("broadcast_notification");
    }
  } else {
    await _firebaseMessaging.requestPermission();
  }
}

class CFQ extends StatefulWidget {
  const CFQ({Key? key}) : super(key: key);

  @override
  State<CFQ> createState() => _CFQState();
}

class _CFQState extends State<CFQ> {
  late FlutterLocalNotificationsPlugin fltNotification;

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    fltNotification = FlutterLocalNotificationsPlugin();
    await fltNotification.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        '1',
        'cfq_notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const generalDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await fltNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        generalDetails,
      );
    }
  }

  Future<void> _manageFCMToken(String uid) async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // For iOS: Ensure APNS token is retrieved
      if (Platform.isIOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null) {
          print('Failed to retrieve APNS token.');
          return;
        }
      }

      // Get FCM token and update Firestore
      String? token = await messaging.getToken();
      if (token == null) return;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final userData = await userDoc.get();

      if (userData.exists) {
        final currentToken = userData.data()?['tokenFCM'];
        if (currentToken != token) {
          await userDoc.update({'tokenFCM': token});
        }
      } else {
        await userDoc.set({'tokenFCM': token}, SetOptions(merge: true));
      }

      // Listen to token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _manageFCMToken(uid);
      });
    } catch (e) {
      print('Error managing FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CFQ',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: CustomColor.transparent,
        ),
        home: NeonBackground(
          child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data?.uid != null) {
                  final uid = snapshot.data!.uid;
                  _manageFCMToken(uid);
                  return FutureBuilder<bool>(
                    future: _doesUserExist(uid),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CustomColor.customWhite,
                          ),
                        );
                      }
                      if (userSnapshot.hasData && userSnapshot.data == true) {
                        return RepsonsiveLayout(
                          mobileScreenLayout: MobileScreenLayout(uid: uid),
                          webScreenLayout: WebScreenLayout(),
                        );
                      } else {
                        return const LoginScreenMobile();
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: CustomColor.customWhite,
                  ),
                );
              }
              return const LoginScreenMobile();
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _doesUserExist(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
  }
}

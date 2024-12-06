import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  await Firebase.initializeApp();
  AppLogger.debug("Background message received: ${message}");

  // Handle both data and notification messages
  if (message.data.isNotEmpty) {
    final String? eventType = message.data['event'];
    if (eventType == "daily_ask_turn") {
      AppLogger.debug("Daily ask turn event reçu");
      final MethodChannel _channel =
          const MethodChannel("notifications_channel");
      await _channel.invokeMethod("scheduleNotification");
    }
    if (eventType == "daily_ask_turn_already") {
      AppLogger.debug("Daily ask turn event AGAIN reçu");
      final MethodChannel _channel =
          const MethodChannel("notifications_channel");
      await _channel.invokeMethod("scheduleNotification");
    }
  }

  // Handle notification payload if present
  if (message.notification != null) {
    // You might want to show a local notification here
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

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

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      generalDetails,
    );
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

  // Request permissions first
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Set foreground notification options
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Subscribe to topics with retry logic
  await _subscribeToTopicsWithRetry(messaging);

  // Set up background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _setupNotificationListener();
}

Future<void> _subscribeToTopicsWithRetry(FirebaseMessaging messaging,
    {int maxRetries = 3}) async {
  int retryCount = 0;
  bool subscribed = false;

  while (!subscribed && retryCount < maxRetries) {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          await messaging.subscribeToTopic("daily_ask_turn");
          await messaging.subscribeToTopic("broadcast_notification");
          subscribed = true;
        }
      } else {
        await messaging.subscribeToTopic("daily_ask_turn");
        await messaging.subscribeToTopic("broadcast_notification");
        subscribed = true;
      }
    } catch (e) {
      retryCount++;
      await Future.delayed(Duration(seconds: 2 * retryCount));
    }
  }

  if (!subscribed) {
    AppLogger.debug('Failed to subscribe to topics after $maxRetries attempts');
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
    _initializeMessageHandling();
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
          AppLogger.debug('Failed to retrieve APNS token.');
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
      AppLogger.debug('Error managing FCM token: $e');
    }
  }

  Future<void> _initializeMessageHandling() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.debug("Foreground message received: ${message}");

      // Handle data messages
      if (message.data.isNotEmpty) {
        final String? eventType = message.data['event'];
        if (eventType == "daily_ask_turn") {
          AppLogger.debug("Daily ask turn event received in foreground");
          final MethodChannel _channel =
              const MethodChannel("notifications_channel");
          await _channel.invokeMethod("scheduleNotification");
        }
        if (eventType == "daily_ask_turn_already") {
          AppLogger.debug("Daily ask turn AGAIN event received in foreground");
          final MethodChannel _channel =
              const MethodChannel("notifications_channel");
          await _channel.invokeMethod("scheduleNotification");
        }
      }

      // Handle notification messages
      if (message.notification != null) {
        await _showNotification(message);
      }
    });

    // Handle message open events
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _processMessage(message);
    });
  }

  Future<void> _processMessage(RemoteMessage message) async {
    // Handle data messages
    if (message.data.isNotEmpty) {
      final String? event = message.data['event'];
      if (event == 'daily_ask_turn') {
        await _showCustomNotification(
          title: 'CFQ ?',
          body: message.data['message'] ?? 'Ca turn ce soir ?',
        );
      }
    }

    // Handle notification messages
    if (message.notification != null) {
      await _showNotification(message);
    }
  }

  Future<void> _showCustomNotification({
    required String title,
    required String body,
  }) async {
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
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      body,
      generalDetails,
    );
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

import 'dart:io';

import 'package:cfq_dev/providers/auth_methods.dart';
import 'package:cfq_dev/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/login_screen_phone.dart';
import 'package:cfq_dev/utils/styles/colors.dart';
import 'package:cfq_dev/utils/styles/neon_background.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Message reçu en arrière-plan : ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

// Configure Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  runApp(const CFQ());
}

void subscribeToTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic('all_users');
  // Abonne l'utilisateur au topic 'all_users'
}

Future<void> requestNotificationPermission2() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Pour iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("Notifications autorisées !");
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print("Notifications refusées !");
  }
}

void initNotification() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //if (currentUser != null) {
  if (Platform.isIOS) {
    String? apnsToken = await _firebaseMessaging.getAPNSToken();
    print("@@@ apnsToken = $apnsToken");
    if (apnsToken != null) {
      await _firebaseMessaging.requestPermission();
      await _firebaseMessaging.subscribeToTopic("all_users");
    }
  } else {
    await _firebaseMessaging.requestPermission();
  }
  //}
}

listenNotifFromFirebase() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      // Affiche une notification locale
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Rappels quotidiens',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}

Future<void> updateIsActiveStatus(bool isActive) async {
  try {
    await AuthMethods().updateIsActiveStatus(isActive);
  } catch (e) {
    AppLogger.error(e.toString());
  }
}

Future<void> requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.notification.request();
  }

  if (status.isGranted) {
    print("Permission de notifications accordée !");
  } else if (status.isPermanentlyDenied) {
    print("Permission de notifications refusée de manière permanente !");
    // Redirige vers les paramètres de l'application
    // await openAppSettings();
  } else {
    print("Permission de notifications refusée.");
  }
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onNotificationResponse,
  );
}

void onNotificationResponse(NotificationResponse response) {
  if (response.actionId == 'validate') {
    print('@@@ L’utilisateur a validé l’élément.');
  } else if (response.actionId == 'cancel') {
    print('@@@ L’utilisateur a annulé l’action.');
  }
}

class CFQ extends StatefulWidget {
  const CFQ({super.key});

  @override
  State<CFQ> createState() => _CFQState();
}

class _CFQState extends State<CFQ> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin fltNotification;

  @override
  void initState() {
    _removeSplashScreen();
    initMessaging();
    super.initState();
  }

  void initMessaging() {
    var androiInit =
        const AndroidInitializationSettings("@mipmap/ic_launcher"); //for logo
    var iosInit = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    fltNotification = FlutterLocalNotificationsPlugin();
    fltNotification.initialize(initSetting);

    var androidDetails = const AndroidNotificationDetails("1", "casden");

    var iosDetails = const DarwinNotificationDetails();

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        AndroidNotification? android = message.notification?.android;
        if (android != null) {
          fltNotification.show(notification.hashCode, notification.title,
              notification.body, generalNotificationDetails);
        }
      }
    });
  }

  Future<void> _manageFCMToken(String uid) async {
    try {
      // For iOS: Wait for APNS token and handle it properly
      if (Platform.isIOS) {
        // First request permissions
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // Get APNS token with retry logic

        String? apnsToken;
        int retryCount = 0;
        while (apnsToken == null && retryCount < 3) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            retryCount++;
            await Future.delayed(const Duration(seconds: 2));
          }
        }

        // Only proceed if we have an APNS token
        if (apnsToken == null) {
          print('Failed to get APNS token after retries');
          return;
        }
      }

      // Now safe to get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      // Update token in Firestore
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

  Future<void> _removeSplashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> _doesUserExist(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'cfq_dev',
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
}

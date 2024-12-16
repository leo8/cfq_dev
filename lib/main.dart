import 'dart:convert';
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
import 'package:crypto/crypto.dart';

// Initialize notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.debug("Background message received: ${message}");

  if (message.data.isNotEmpty) {
    final String? eventType = message.data['event'];
    if (eventType == "daily_ask_turn" ||
        eventType == "daily_ask_turn_already") {
      _scheduleNotification();
    }
  }

  if (message.notification != null) {
    await _showNotification(
      title: message.notification!.title,
      body: message.notification!.body,
    );
  }
}

Future<void> _scheduleNotification() async {
  const MethodChannel _channel = MethodChannel("notifications_channel");
  await _channel.invokeMethod("scheduleNotification");
}

// Fonction pour générer un ID entier à partir de conversationId
int generateNotificationId(String conversationId) {
  var bytes = utf8.encode(conversationId); // Convertir en bytes
  var digest = md5.convert(bytes); // Générer un hash MD5
  var convertInt =
      Uint8List.fromList(digest.bytes).buffer.asByteData().getUint32(0);
  print("@@@ generateNotificationId = $convertInt");
  return convertInt;
}

// Utiliser generateNotificationId dans _showNotification
Future<void> _showNotification(
    {String? title, String? body, String? conversationId}) async {
  const androidDetails = AndroidNotificationDetails('1', 'cfq_notifications',
      importance: Importance.high, priority: Priority.high, autoCancel: true);
  const iosDetails = DarwinNotificationDetails();
  const generalDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  int notificationId = conversationId != null
      ? generateNotificationId(conversationId)
      : DateTime.now().millisecondsSinceEpoch.hashCode;

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    body,
    generalDetails,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initializeFirebaseMessaging();
  runApp(const CFQ());
}

Future<void> _initializeFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class CFQ extends StatefulWidget {
  const CFQ({Key? key}) : super(key: key);

  @override
  State<CFQ> createState() => _CFQState();
}

class _CFQState extends State<CFQ> {
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

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _initializeMessageHandling() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.debug("Foreground message received: ${message}");

      // Vérifier si vous devez gérer manuellement les notifications
      if (message.data.isNotEmpty) {
        final String? eventType = message.data['event'];
        if (eventType == "daily_ask_turn" ||
            eventType == "daily_ask_turn_already") {
          _scheduleNotification();
        }
      }

      if (message.notification != null &&
          !(Platform.isIOS || Platform.isAndroid)) {
        await _showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
      }
    });

// Dans onMessageOpenedApp
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      AppLogger.debug("Message ouvert depuis une notification : ${message}");

      print("@@@ ${message.data.containsKey('conversationId')}");
      if (message.data.containsKey('conversationId')) {
        final conversationId = message.data['conversationId'];
        print("@@@ ici");
        print("@@@ conversationId = ${conversationId}");
        print(
            "@@@ generateNotificationId(conversationId) = ${generateNotificationId(conversationId)}");
        print(
            "@@@ generateNotificationId(conversationId) = ${generateNotificationId(conversationId)}");
        //flutterLocalNotificationsPlugin
        //    .cancel(generateNotificationId(conversationId));
        flutterLocalNotificationsPlugin.cancelAll();
      }

      if (message.notification != null) {
        print('Notification clicked: ${message.notification?.title}');
      }
    });
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
                  return _buildUserScreen(uid);
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

  Future<void> _manageFCMToken(String uid) async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      if (token != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        await userDoc.set({'tokenFCM': token}, SetOptions(merge: true));

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          await userDoc.update({'tokenFCM': newToken});
        });
      }
    } catch (e) {
      AppLogger.debug('Error managing FCM token: $e');
    }
  }

  Widget _buildUserScreen(String uid) {
    return FutureBuilder<bool>(
      future: _doesUserExist(uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
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
  }

  Future<bool> _doesUserExist(String uid) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);
    return (await doc.get()).exists;
  }
}

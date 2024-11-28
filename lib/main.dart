import 'package:cfq_dev/providers/user_provider.dart';
import 'package:cfq_dev/responsive/mobile_screen_layout.dart';
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart';
import 'package:cfq_dev/responsive/web_screen_layout.dart';
import 'package:cfq_dev/screens/login/login_screen_phone.dart';
import 'package:cfq_dev/utils/styles/colors.dart'; // Custom color definitions
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core
import 'package:flutter/material.dart'; // Flutter material components
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Splash screen management
import 'package:cfq_dev/utils/styles/neon_background.dart'; // Neon background template
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding
      .ensureInitialized(); // Ensure bindings are initialized
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterNativeSplash.preserve(
      widgetsBinding: widgetsBinding); // Preserve splash screen until ready

  // Initialize Firebase for mobile platforms
  await Firebase.initializeApp();

  // Add FCM permission request
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const CFQ()); // Run the application
}

class CFQ extends StatefulWidget {
  const CFQ({super.key});

  @override
  State<CFQ> createState() => _CFQState();
}

class _CFQState extends State<CFQ> {
  @override
  void initState() {
    super.initState();
    _removeSplashScreen(); // Remove splash screen after initialization
  }

  // Remove splash screen when app is ready
  Future<void> _removeSplashScreen() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Optionally delay for some time
    FlutterNativeSplash.remove(); // Remove the splash screen
  }

  Future<bool> _doesUserExist(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Add this new method to manage FCM token
  Future<void> _manageFCMToken(String uid) async {
    try {
      // For iOS: Wait for APNS token and handle it properly
      if (Platform.isIOS) {
        // First request permissions
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional:
              true, // This allows users to choose notification type later
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

  // Root widget of the application
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              UserProvider(), // Provide UserProvider to the widget tree
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
                  // Add FCM token management here
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
        routes: {
          '/login': (context) =>
              const NeonBackground(child: LoginScreenMobile()),
        },
      ),
    );
  }
}

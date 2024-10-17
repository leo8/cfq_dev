import 'package:cfq_dev/providers/user_provider.dart'; // User provider for state management
import 'package:cfq_dev/responsive/mobile_screen_layout.dart'; // Mobile layout
import 'package:cfq_dev/responsive/repsonsive_layout_screen.dart'; // Responsive layout
import 'package:cfq_dev/responsive/web_screen_layout.dart'; // Web layout
import 'package:cfq_dev/screens/login_screen.dart'; // Login screen
import 'package:cfq_dev/utils/styles/colors.dart'; // Custom color definitions
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:firebase_core/firebase_core.dart'; // Firebase core
import 'package:flutter/foundation.dart'; // Flutter foundation for platform checks
import 'package:flutter/material.dart'; // Flutter material components
import 'package:provider/provider.dart'; // State management using Provider
import 'secrets/secrets_firebase.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Splash screen management
import 'package:cfq_dev/utils/styles/neon_background.dart'; // Neon background template

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding
      .ensureInitialized(); // Ensure bindings are initialized
  FlutterNativeSplash.preserve(
      widgetsBinding: widgetsBinding); // Preserve splash screen until ready

  // Initialize Firebase for web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey, // Your API key
        appId: appId, // Your app ID
        messagingSenderId: messagingSenderId, // Sender ID
        projectId: projectId, // Project ID
        storageBucket: storageBucket, // Storage bucket
      ),
    );
  } else {
    // Initialize Firebase for mobile platforms
    await Firebase.initializeApp();
  }

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
                if (snapshot.hasData) {
                  return const RepsonsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
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
              return const LoginScreen();
            },
          ),
        ),
        routes: {
          '/login': (context) => const NeonBackground(child: LoginScreen()),
        },
      ),
    );
  }
}

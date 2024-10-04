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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
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
  runApp(const MyApp()); // Run the application
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        debugShowCheckedModeBanner: false, // Hide debug banner
        title: 'cfq_dev', // App title
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor:
              CustomColor.mobileBackgroundColor, // Set the background color
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance
              .authStateChanges(), // Listen for authentication state changes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // User is logged in
                return const RepsonsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(), // Mobile layout
                  webScreenLayout: WebScreenLayout(), // Web layout
                );
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('${snapshot.error}')); // Show error message
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Waiting for authentication state
              return const Center(
                child: CircularProgressIndicator(
                  color: CustomColor.white, // Loading indicator color
                ),
              );
            }
            return LoginScreen(); // Show login screen if not authenticated
          },
        ),
      ),
    );
  }
}

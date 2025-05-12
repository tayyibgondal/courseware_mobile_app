import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'services/dummy_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Initialize Firestore settings for web
    if (kIsWeb) {
      debugPrint('Configuring Firestore for web');
      // No special configuration needed for newer Firebase Web SDK
    }
    
    // Initialize dummy courses data
    final dummyDataService = DummyDataService();
    await dummyDataService.addDummyCourses();
    
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  
  runApp(const OpenCoursewareApp());
}

class OpenCoursewareApp extends StatelessWidget {
  const OpenCoursewareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Courseware',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          // Handle passing the index to the home screen
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              initialIndex: args is int ? args : 0,
            ),
          );
        }
        // Fall back to the regular named routes
        return null;
      },
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

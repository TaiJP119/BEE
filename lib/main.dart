import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:BEE_APP/features/app/splash_screen/splash_screen.dart';
import 'package:BEE_APP/features/user_auth/presentation/pages/home_page.dart';
import 'package:BEE_APP/features/user_auth/presentation/pages/login_page.dart';
import 'package:BEE_APP/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:BEE_APP/features/user_auth/presentation/pages/ai_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCm1EYBB0ONvHqBEbGBSKZkyN1cxpYFoik",
        appId: "1:517136538140:web:ef2d6b4e3b798cd0f41dd9",
        messagingSenderId: "517136538140",
        projectId: "BEE",
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bee_App',
      routes: {
        '/': (context) => SplashScreen(
              // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/ai': (context) => AIPage(),
      },
    );
  }
}

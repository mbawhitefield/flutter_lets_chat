import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lets_chat/screens/chat/chat_screen.dart';
import 'package:flutter_lets_chat/screens/loginScreen/login_screen.dart';
import 'package:flutter_lets_chat/screens/signUpScreen/signup_screen.dart';
import 'package:flutter_lets_chat/screens/welcomeScreen/welcome_screen.dart';
import 'package:flutter_lets_chat/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme(context),
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.routeName,
      // home: StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child:  CircularProgressIndicator());
      //     }

      //     if (snapshot.hasData) {
      //       return const ChatScreen();
      //     }
      //     return const LoginScreen();
      //   },
      // ),
      routes: {
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
      },
    );
  }
}

// main.dart

import 'package:chatify/screens/welcome_screen.dart';
import 'package:chatify/screens/chats_screen.dart';
import 'package:chatify/utils/notification_service.dart'; // Importujemy NotificationService
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'constants/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Chatify',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.dark,
      home: currentUser != null ? const ChatsScreen() : const WelcomeScreen(),
    );
  }
}

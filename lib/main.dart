import 'dart:developer' as developer;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/auth_screen.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/home_screen.dart';
import 'package:kyros/splash_screen.dart';

import 'firebase_options.dart';
import 'note_screen.dart';

void main() async {
  developer.log('Starting app...', name: 'kyros.main');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  developer.log('Firebase initialized.', name: 'kyros.main');
  runApp(const KyrosApp());
}

class KyrosApp extends StatelessWidget {
  const KyrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.latoTextTheme();

    return MaterialApp(
      title: 'Kyros',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008080), // Teal
          primary: const Color(0xFF008080), // Teal
          secondary: const Color(0xFF9B89B3), // Muted Lilac
          background: const Color(0xFFF0F4F8), // Desaturated Blue-White
          surface: const Color(0xFFF0F4F8), // Desaturated Blue-White
          onSurface: const Color(0xFF2C3E50), // Dark Slate Navy
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF2C3E50),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF2C3E50),
          displayColor: const Color(0xFF2C3E50),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF008080),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF008080), fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Color(0xFF008080));
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Color(0xFF008080));
          }),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return HomeScreen(userId: snapshot.data!.uid);
          } else {
            return const AuthScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(userId: FirebaseAuth.instance.currentUser!.uid),
        '/bible_lookup': (context) => const BibleLookupScreen(),
        '/notes': (context) => NoteScreen(userId: FirebaseAuth.instance.currentUser!.uid),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

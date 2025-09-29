import 'dart:developer' as developer;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/auth_screen.dart';
import 'package:myapp/bible_lookup_screen.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/splash_screen.dart';

import 'firebase_options.dart';
import 'note_screen.dart';

void main() async {
  developer.log('Starting app...', name: 'myapp.main');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  developer.log('Firebase initialized.', name: 'myapp.main');
  runApp(const ChurchPadApp());
}

class ChurchPadApp extends StatelessWidget {
  const ChurchPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.latoTextTheme();

    return MaterialApp(
      title: 'ChurchPad Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE5EDF8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF334155),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF2563EB),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: Color(0xFF64748B));
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Color(0xFF64748B));
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

import 'dart:developer' as developer;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/auth_screen.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/highlight_service.dart';
import 'package:kyros/collections_screen.dart';
import 'package:kyros/home_screen.dart';
import 'package:kyros/l10n/app_localizations.dart';
import 'package:kyros/splash_screen.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => HighlightService()),
      ],
      child: const KyrosApp(),
    ),
  );
}

class KyrosApp extends StatelessWidget {
  const KyrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF008080); // Teal

    final TextTheme appTextTheme = GoogleFonts.latoTextTheme();

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        primary: primarySeedColor,
        secondary: const Color(0xFF9B89B3), // Muted Lilac
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      textTheme: appTextTheme.apply(
        bodyColor: const Color(0xFF2C3E50),
        displayColor: const Color(0xFF2C3E50),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primarySeedColor,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
                color: primarySeedColor, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: primarySeedColor);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: primarySeedColor);
        }),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        primary: primarySeedColor,
        secondary: const Color(0xFF9B89B3), // Muted Lilac
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle:
            GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.teal.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Kyros',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
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
            '/home': (context) =>
                HomeScreen(userId: FirebaseAuth.instance.currentUser!.uid),
            '/bible_lookup': (context) => const BibleLookupScreen(),
            '/collections': (context) => const CollectionsScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

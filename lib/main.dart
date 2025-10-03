
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/auth_screen.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/collections_screen.dart';
import 'package:kyros/highlight_service.dart';
import 'package:kyros/home_screen.dart';
import 'package:kyros/settings_screen.dart';
import 'package:kyros/splash_screen.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
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
    // Define the custom color palette
    const Color primaryColor = Color(0xFF008080); // Teal
    const Color secondaryColor = Color(0xFFC8A2C8); // Lilac
    const Color lightBackgroundColor = Color(0xFFF0F8FF); // Alice Blue
    const Color darkBackgroundColor = Color(0xFF29465B); // Dark Slate Blue

    // Define a common TextTheme
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    // --- Static Light Theme ---
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      secondary: secondaryColor,
    ).copyWith(
      surface: lightBackgroundColor, // Use surface for main background
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // --- Static Dark Theme ---
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      secondary: secondaryColor,
    ).copyWith(
      surface: darkBackgroundColor,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimaryContainer,
          backgroundColor: darkColorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            ThemeData activeLightTheme = lightTheme;
            ThemeData activeDarkTheme = darkTheme;

            if (themeProvider.isDynamic && lightDynamic != null && darkDynamic != null) {
              activeLightTheme = ThemeData(
                useMaterial3: true,
                colorScheme: lightDynamic,
                textTheme: appTextTheme,
              );
              activeDarkTheme = ThemeData(
                useMaterial3: true,
                colorScheme: darkDynamic,
                textTheme: appTextTheme,
              );
            }

            return MaterialApp(
              title: 'Kyros',
              theme: activeLightTheme,
              darkTheme: activeDarkTheme,
              themeMode: themeProvider.themeMode,
              localizationsDelegates: const [
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
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
                '/settings': (context) => const SettingsScreen(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

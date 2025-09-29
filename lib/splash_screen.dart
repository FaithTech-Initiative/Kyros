import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(flex: 2),
              Image.asset(
                'assets/Study notebook and pencil.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'Kyros',
                style: GoogleFonts.lato(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Capture Insights. Deepen Your Study',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

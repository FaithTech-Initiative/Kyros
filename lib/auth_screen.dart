import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kyros/home_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;

  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _navigateToHome(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed.')));
    }
  }

  Future<void> _createUserWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await userCredential.user?.updateDisplayName(_nameController.text);
      if (!mounted) return;
      _navigateToHome(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign up failed.')));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleSignInAuthentication =
          googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.idToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (!mounted) return;
      _navigateToHome(userCredential.user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google Sign in failed: $e')));
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credentialWithApple = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credentialWithApple);
      if (!mounted) return;
      _navigateToHome(userCredential.user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Apple Sign in failed: $e')));
    }
  }

  void _navigateToHome(User? user) {
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(userId: user.uid)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Kyros',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'A distraction-free space for your thoughts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                if (!_isLogin) _buildOnboardingCarousel(),
                _buildAuthCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingCarousel() {
    final List<Map<String, String>> carouselItems = [
      {
        'imagePath': 'assets/images/carousel_1.png',
        'title': 'Capture Freely',
        'subtitle':
            'A distraction-free space to capture sermon notes and insights, just like pen and paper.',
      },
      {
        'imagePath': 'assets/images/carousel_2.png',
        'title': 'Study Deeply',
        'subtitle':
            'Instantly reference Bible verses and explore definitions right inside your notes.',
      },
      {
        'imagePath': 'assets/images/carousel_3.png',
        'title': 'Organize Intuitively',
        'subtitle':
            'Go beyond simple notes. Turn fleeting thoughts into a permanent knowledge base for your faith.',
      },
    ];

    return FlutterCarousel.builder(
      itemCount: carouselItems.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final item = carouselItems[itemIndex];
        return _buildCarouselItem(
          item['imagePath']!,
          item['title']!,
          item['subtitle']!,
        );
      },
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        showIndicator: true,
        slideIndicator: const CircularSlideIndicator(),
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath, String title, String subtitle) {
    return Column(
      children: [
        Image.asset(imagePath, height: 100),
        const SizedBox(height: 10),
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isLogin) _buildNameField(),
          if (!_isLogin) const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          _buildAuthButton(),
          _buildToggleAuthModeButton(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Name',
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email address',
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
    );
  }

  Widget _buildAuthButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      onPressed: _isLogin
          ? _signInWithEmailAndPassword
          : _createUserWithEmailAndPassword,
      child: Text(
        _isLogin ? 'Sign In' : 'Sign Up',
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildToggleAuthModeButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Text(
        _isLogin
            ? 'Don\'t have an account? Sign Up'
            : 'Already have an account? Sign In',
        style: GoogleFonts.lato(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Or continue with',
              style: GoogleFonts.lato(color: Colors.grey)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/google_logo.png',
          _signInWithGoogle,
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          'assets/images/apple_logo.png',
          _signInWithApple,
        ),
      ],
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      child: Image.asset(imagePath, height: 24.0),
    );
  }
}

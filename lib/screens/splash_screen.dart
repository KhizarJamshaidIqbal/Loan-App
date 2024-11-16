import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    // Navigate based on auth status
    if (currentUser != null) {
      Navigator.pushReplacementNamed(context, '/mainPage');
    } else {
      Navigator.pushReplacementNamed(context, '/loginPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9FF7E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo2.png',
            )
                .animate()
                .slideY(
                  begin: 1.0,
                  end: 0.0,
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutQuad,
                )
                .fadeIn(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 500),
                ),
          ],
        ),
      ),
    );
  }
}

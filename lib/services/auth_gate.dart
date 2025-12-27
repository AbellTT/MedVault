import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/dashboard%20flow/dashboard_screen.dart';
import 'package:app/screens/signup_screen.dart';

class AuthGate extends StatefulWidget {
  final ValueChanged<bool> toggleDarkMode;
  const AuthGate({super.key, required this.toggleDarkMode});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isTimerDone = false;

  @override
  void initState() {
    super.initState();
    // Ensure splash screen lasts at least 2 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen if still checking auth OR minimum time hasn't passed
        if (snapshot.connectionState == ConnectionState.waiting ||
            !_isTimerDone) {
          return const SplashScreen(showLoading: true);
        }

        if (snapshot.hasData) {
          return DashboardScreen(toggleDarkMode: widget.toggleDarkMode);
        }

        return const SignUpScreen();
      },
    );
  }
}

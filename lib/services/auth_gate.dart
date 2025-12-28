import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/dashboard flow/dashboard_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/services/biometric_service.dart';
import 'package:app/screens/app_lock_screen.dart';

class AuthGate extends StatefulWidget {
  final ValueChanged<bool> toggleDarkMode;
  const AuthGate({super.key, required this.toggleDarkMode});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isTimerDone = false;
  bool _isBiometricAuthenticated = false;
  bool _isBiometricRequirementChecked = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricPreference();
    // Ensure splash/transition lasts at least 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
      }
    });
  }

  Future<void> _checkBiometricPreference() async {
    final enabled = await BiometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _isBiometricRequirementChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Initial Auth State Check
        if (snapshot.connectionState == ConnectionState.waiting ||
            !_isBiometricRequirementChecked) {
          return const SplashScreen(showLoading: true);
        }

        final user = snapshot.data;

        // 2. Not Logged In
        if (user == null) {
          return const SignUpScreen();
        }

        // 3. Logged In + Biometric Lock
        if (_isBiometricEnabled && !_isBiometricAuthenticated) {
          return AppLockScreen(
            onUnlocked: () {
              setState(() {
                _isBiometricAuthenticated = true;
                // We reset the timer when unlocking to show splash for a bit
                _isTimerDone = false;
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) setState(() => _isTimerDone = true);
                });
              });
            },
          );
        }

        // 4. Loading/Transition State
        if (!_isTimerDone) {
          return const SplashScreen(showLoading: true);
        }

        // 5. Final Destination
        return DashboardScreen(toggleDarkMode: widget.toggleDarkMode);
      },
    );
  }
}

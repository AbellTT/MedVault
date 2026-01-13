import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/dashboard flow/dashboard_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/services/biometric_service.dart';
import 'package:app/screens/app_lock_screen.dart';
import 'package:app/screens/user setup flow/get_started_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isSetupComplete = false;
  bool _isSetupCompleteChecked = false;
  String? _currentUserId;
  late Stream<User?> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = FirebaseAuth.instance.authStateChanges();
    // Cold Boot Splash Timer
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isTimerDone = true;
        });
      }
    });
  }

  Future<void> _checkBiometricPreference(String uid) async {
    final enabled = await BiometricService.isBiometricEnabled(uid);
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _isBiometricRequirementChecked = true;
      });
    }
  }

  Future<void> _checkSetupStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (mounted) {
        setState(() {
          _isSetupComplete = data != null && data['setup_complete'] == true;
          _isSetupCompleteChecked = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSetupComplete = false;
          _isSetupCompleteChecked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        // 1. Initial State Check (Cold Boot)
        // Ensure splash shows for 3 seconds initially
        if (!_isTimerDone ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(showLoading: true);
        }

        final user = snapshot.data;

        // 2. Not Logged In
        if (user == null) {
          _isSetupCompleteChecked = false;
          _currentUserId = null;
          _isBiometricAuthenticated = false; // Reset for next login
          return const SignUpScreen();
        }

        // 3. User Found - Check Setup Status & Biometrics (only once per user ID)
        if (_currentUserId != user.uid) {
          _currentUserId = user.uid;
          _isSetupCompleteChecked = false;
          _isBiometricRequirementChecked =
              false; // Reset to check for this specific user
          _checkSetupStatus(user.uid);
          _checkBiometricPreference(user.uid);
          return const SplashScreen(showLoading: true);
        }

        if (!_isSetupCompleteChecked || !_isBiometricRequirementChecked) {
          return const SplashScreen(showLoading: true);
        }

        // 4. Force Onboarding if incomplete
        if (!_isSetupComplete) {
          return const GetStartedScreen();
        }

        // 5. Bio Lock (if enabled and not yet unlocked)
        if (_isBiometricEnabled && !_isBiometricAuthenticated) {
          return AppLockScreen(
            onUnlocked: () {
              setState(() {
                _isBiometricAuthenticated = true;
                // Transition immediately to Dashboard - no extra splash
              });
            },
          );
        }

        // 6. Final Dashboard
        return DashboardScreen(toggleDarkMode: widget.toggleDarkMode);
      },
    );
  }
}

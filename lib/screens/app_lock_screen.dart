import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/utils/color_extensions.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isAuthenticating = false;
  String _statusMessage = 'Scan your fingerprint to access MedVault';

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometrics on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Authenticating...';
    });

    final authenticated = await BiometricService.authenticate(
      localizedReason: 'Please authenticate to access MedVault',
    );

    if (authenticated) {
      widget.onUnlocked();
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _statusMessage = 'Authentication failed. Please try again.';
        });
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white.themedWith(isDark),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Lock Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FF).themedWith(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/icon for Medvault/Lock.svg',
                    width: 64,
                    height: 64,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF277AFF).themedWith(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'MedVault Locked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF1A1A1A).themedWith(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF757575).themedWith(isDark),
                  ),
                ),
                const SizedBox(height: 48),
                // Unlock Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF277AFF,
                      ).themedWith(isDark),
                      foregroundColor: Colors.white.themedWith(isDark),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isAuthenticating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Unlock Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),
                const Spacer(),
                // Sign Out Option
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out of Account',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

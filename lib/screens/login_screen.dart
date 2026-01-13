import 'package:app/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/connectivity_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final authService = AuthService();
  int selected = 1; // 0 = Sign Up, 1 = Login
  bool _obscurePassword = true;
  bool rememberMe = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<bool> loginUser() async {
    final messenger = ScaffoldMessenger.of(context);

    // Check internet first
    final hasInternet = await ConnectivityHelper.hasInternet();
    if (!hasInternet) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please connect to log in."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Check if widget is still mounted before showing snackbar
      if (!context.mounted) return true;
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Logged in successfully"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return true; // Return true on success
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Invalid email or password. Please try again.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else {
        message = e.message ?? 'Authentication error.';
      }
      // Check if widget is still mounted
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
      return false;
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  SvgPicture.asset(
                    'assets/images/icon.svg',
                    width: 32,
                    height: 40,
                  ),

                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    height: 70,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Med",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF277AFF).themedWith(isDark),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: "Vault",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3AC0A0).themedWith(isDark),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    height: 50,
                    child: Text(
                      "Your Health, Simplified & Secured",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFF61677D).themedWith(isDark),
                        fontFamily: 'Inter_28pt-Regular',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // ⭐ controls the whole widget width
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              // color: Color(0xFF61677D),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              // color: Color(0xFF61677D),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      selected: {selected},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          selected = newSelection.first;
                        });

                        if (selected == 0) {
                          Navigator.pushReplacementNamed(context, '/signup');
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ButtonStyle(
                        // Border color
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: const Color(0xFF3AC0A0).themedWith(isDark),
                            width: 2,
                          ),
                        ),

                        // Rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Background colors
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(
                              0xFF3AC0A0,
                            ); // selected background
                          }
                          return Colors.white.themed(
                            context,
                          ); // unselected background
                        }),

                        // Text color
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white; // selected text color
                          }
                          return const Color(
                            0xFF2B2F33,
                          ).themedWith(isDark); // unselected text color
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,

                      // Change floating label color
                      floatingLabelStyle: TextStyle(
                        color: const Color(
                          0xFF277AFF,
                        ).themedWith(isDark), // change to any color you want
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter_28pt-Regular",
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color.fromARGB(
                            255,
                            223,
                            227,
                            230,
                          ).themedWith(isDark),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),

                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your email";
                      }
                      if (!value.contains("@")) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,

                      // Change floating label color
                      floatingLabelStyle: TextStyle(
                        color: const Color(
                          0xFF277AFF,
                        ).themedWith(isDark), // change to any color you want
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter_28pt-Regular",
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color.fromARGB(
                            255,
                            223,
                            227,
                            230,
                          ).themedWith(isDark),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),

                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      // 👇 Eye icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // toggle
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                            // Color when the checkbox is checked
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF277AFF);
                              }
                              return Colors.white.themedWith(isDark);
                            }),
                            side: WidgetStateBorderSide.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const BorderSide(
                                  color: Color(0xFF277AFF),
                                  width: 2,
                                );
                              }
                              return BorderSide(
                                color: const Color.fromARGB(
                                  255,
                                  223,
                                  227,
                                  230,
                                ).themedWith(isDark),
                                width: 2,
                              );
                            }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity
                                .compact, // ← reduces default spacing
                          ),
                          Text(
                            "Remember Me",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Inter_28pt-Regular',
                              color: const Color(0xFF6C7278).themedWith(isDark),
                            ),
                          ),
                        ],
                      ),

                      // Forgot Password link
                      GestureDetector(
                        onTap: () {
                          // Navigate to forgot password screen or show dialog
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF277AFF).themedWith(isDark),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.pressed)) {
                              const Color.fromARGB(
                                255,
                                29,
                                88,
                                184,
                              ).themedWith(isDark); // darker green-ish
                            }
                            return const Color(
                              0xFF277AFF,
                            ).themedWith(isDark); // your normal green
                          },
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                bool success = await loginUser();
                                if (success && context.mounted) {
                                  // Smart Redirect: Check if setup is finished
                                  final uid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (uid != null) {
                                    final doc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .get();
                                    final data = doc.data();
                                    final setupComplete =
                                        data != null &&
                                        data['setup_complete'] == true;

                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        setupComplete
                                            ? '/dashboard'
                                            : '/getStarted',
                                        (route) => false,
                                      );
                                    }
                                  }
                                }
                              }
                            },
                      child: _isLoading
                          ? const LoadingAnimation(size: 40)
                          : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: const Color(0xFF6C7278).themedWith(isDark),
                            fontFamily: 'Inter_28pt-Regular',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 15),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(
                            color: const Color(0xFFE2E4E8).themedWith(isDark),
                            width: 1.5,
                          ),
                        ),
                      ),
                      onPressed: _isGoogleLoading
                          ? null
                          : () async {
                              setState(() {
                                _isGoogleLoading = true;
                              });
                              final messenger = ScaffoldMessenger.of(context);

                              // Check internet first
                              final hasInternet =
                                  await ConnectivityHelper.hasInternet();
                              if (!hasInternet) {
                                if (context.mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "No internet connection. Please connect to sign in with Google.",
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                                return;
                              }

                              try {
                                final userCredential = await authService
                                    .signInWithGoogle(isLoginOnly: true);

                                if (userCredential != null) {
                                  if (!context.mounted) return;

                                  // Smart Redirect: Check if setup is finished
                                  final uid = userCredential.user?.uid;
                                  bool setupComplete = false;
                                  if (uid != null) {
                                    final doc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .get();
                                    final data = doc.data();
                                    setupComplete =
                                        data != null &&
                                        data['setup_complete'] == true;
                                  }

                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      setupComplete
                                          ? '/dashboard'
                                          : '/getStarted',
                                      (route) => false,
                                    );

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Signed in with Google successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error: the email you have entered is not registered!!, Please Sign up First',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (context.mounted) {
                                  setState(() {
                                    _isGoogleLoading = false;
                                  });
                                }
                              }
                            },
                      child: _isGoogleLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF277AFF),
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google logo.png',
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(
                                      0xFF2B2F33,
                                    ).themedWith(isDark),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

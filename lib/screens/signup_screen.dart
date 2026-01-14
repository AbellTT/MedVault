import 'package:app/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/services/connectivity_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final authService = AuthService();
  final databaseService = DatabaseService();
  int selected = 0; // 0 = Sign Up, 1 = Login
  bool _obscurePassword = true; // initial state
  bool _isLoading =
      false; // Added loading state to track authentication progress
  bool _isGoogleLoading =
      false; // Added loading state to track Google authentication progress
  Future<bool> createuser() async {
    final messenger = ScaffoldMessenger.of(context);

    // Check internet first
    final hasInternet = await ConnectivityHelper.hasInternet();
    if (!hasInternet) {
      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "No internet connection. Please connect to create an account.",
            ),
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await databaseService.createOrUpdateUserData({
        "account_info": {
          "email": emailController.text.trim(),
          "phone_number": phoneNumberController.text.trim(),
          "created_at": FieldValue.serverTimestamp(),
        },
        'setup_complete': false,
      });
      // Check if widget is still mounted before showing snackbar
      if (!context.mounted) return true;
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Account created successfully"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      return true; // Return true on success
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists with this email.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
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
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      // Change floating label color
                      floatingLabelStyle: TextStyle(
                        color: const Color(0xFF277AFF).themedWith(isDark),
                      ),
                      border: const OutlineInputBorder(),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: "",
                      prefix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+251',
                              style: TextStyle(
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              margin: const EdgeInsets.only(left: 8),
                              color: const Color.fromARGB(
                                144,
                                158,
                                158,
                                158,
                              ).themedWith(isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      final number = int.tryParse(value);
                      if (number == null) {
                        return 'Please enter numbers only';
                      }
                      if (number / 10000000 < 1) {
                        return 'Enter valid phone number';
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
                        color: const Color(0xFF277AFF).themedWith(isDark),
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

                  const SizedBox(height: 20),

                  // Confirm Password
                  TextFormField(
                    controller: confirmController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",

                      floatingLabelBehavior: FloatingLabelBehavior.auto,

                      // Change floating label color
                      floatingLabelStyle: TextStyle(
                        color: const Color(0xFF277AFF).themedWith(isDark),
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
                      if (value != passwordController.text) {
                        return "Password does not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

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
                              ).themedWith(isDark);
                            }
                            return const Color(0xFF277AFF).themedWith(isDark);
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
                          ? null // Disable button while loading
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // Await authentication before navigating
                                bool success = await createuser();
                                if (success && context.mounted) {
                                  Navigator.pushNamed(context, '/getStarted');
                                }
                              }
                            },
                      child: _isLoading
                          ? const LoadingAnimation(size: 40)
                          : const Text(
                              "Sign Up",
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

                  // Google Sign Up Button
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
                          ? null // Disable during loading
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
                                    .signInWithGoogle(isLoginOnly: false);

                                if (userCredential != null) {
                                  if (!context.mounted) return;

                                  // Smart Redirect: Check if setup is finished (in case user meant to log in)
                                  final uid = userCredential.user?.uid;
                                  bool setupComplete = false;
                                  if (uid != null) {
                                    // Ensure account_info is initialized even for existing users (repair affected accounts)
                                    final user = userCredential.user;
                                    await DatabaseService()
                                        .createOrUpdateUserData({
                                          'account_info': {
                                            'email': user?.email,
                                            'profile_picture': user?.photoURL,
                                          },
                                        });

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
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
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
                                  "Sign up with Google",
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

                  const SizedBox(height: 20),
                  // Already have account?
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

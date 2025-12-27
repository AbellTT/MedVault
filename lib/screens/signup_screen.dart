import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final auth_service = new AuthService();
  final database_service = new DatabaseService();
  int selected = 0; // 0 = Sign Up, 1 = Login
  bool _obscurePassword = true; // initial state
  bool _isLoading =
      false; // Added loading state to track authentication progress
  bool _isGoogleLoading =
      false; // Added loading state to track Google authentication progress
  Future<bool> createuser() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await database_service.createOrUpdateUserData({
        "account_info": {
          "email": emailController.text.trim(),
          "phone_number": phoneNumberController.text.trim(),
          "created_at": FieldValue.serverTimestamp(),
        },
        'setup_complete': false,
      });
      // Check if widget is still mounted before showing snackbar
      if (!mounted) return true;
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
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    } catch (e) {
      print("Unexpected error: $e");
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Med",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF277AFF),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: "Vault",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3AC0A0),
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
                    child: const Text(
                      "Your Health, Simplified & Secured",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF61677D),
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
                          const BorderSide(color: Color(0xFF3AC0A0), width: 2),
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
                          return Colors.white; // unselected background
                        }),

                        // Text color
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white; // selected text color
                          }
                          return Colors.black87; // unselected text color
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,

                      // Change floating label color
                      floatingLabelStyle: TextStyle(
                        color: Color(
                          0xFF277AFF,
                        ), // change to any color you want
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter_28pt-Regular",
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 223, 227, 230),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF277AFF),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedErrorBorder: OutlineInputBorder(
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
                      floatingLabelStyle: const TextStyle(
                        color: Color(0xFF277AFF),
                      ),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 223, 227, 230),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF277AFF),
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
                            const Text(
                              '+251',
                              style: TextStyle(
                                color: Color.fromARGB(204, 0, 0, 0),
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              margin: const EdgeInsets.only(left: 8),
                              color: const Color.fromARGB(144, 158, 158, 158),
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
                      floatingLabelStyle: const TextStyle(
                        color: Color(
                          0xFF277AFF,
                        ), // change to any color you want
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter_28pt-Regular",
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 223, 227, 230),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF277AFF),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                      floatingLabelStyle: const TextStyle(
                        color: Color(
                          0xFF277AFF,
                        ), // change to any color you want
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter_28pt-Regular",
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 223, 227, 230),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),

                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF277AFF),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                              return const Color.fromARGB(255, 29, 88, 184);
                            }
                            return const Color(0xFF277AFF);
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
                                if (success && mounted) {
                                  Navigator.pushNamed(context, '/getStarted');
                                }
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ) // [CHANGE] Show loader when busy
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
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Inter_28pt-Regular',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey.shade300,
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
                          BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                      ),
                      onPressed: _isGoogleLoading
                          ? null // Disable during loading
                          : () async {
                              setState(() {
                                _isGoogleLoading = true;
                              });
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              try {
                                final userCredential = await auth_service
                                    .signInWithGoogle(isLoginOnly: false);

                                if (userCredential != null) {
                                  if (!mounted) return;
                                  await navigator.pushNamed('/getStarted');
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
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
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
                                const Text(
                                  "Sign up with Google",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
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

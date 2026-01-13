import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/services/email_service.dart';
import 'dart:math';
import 'package:app/utils/color_extensions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isLoading = false;

  String _generateOTP() {
    return (Random().nextInt(90000) + 10000).toString();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final otp = _generateOTP();

    try {
      // 1. Store OTP in Firestore with timestamp for verification
      await FirebaseFirestore.instance
          .collection('password_reset_otps')
          .doc(email)
          .set({
            'otp': otp,
            'email': email,
            'created_at': FieldValue.serverTimestamp(),
            'expires_at': DateTime.now().add(const Duration(minutes: 10)),
          });

      // 2. Send Email via EmailJS
      final emailSent = await EmailService.sendOTP(email: email, otp: otp);

      if (emailSent) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/Enter-Otp', arguments: email);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft, // ← left alignment
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      alignment: Alignment.center,
                      width: 250,
                      height: 50,
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 28,
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: 350,
                      height: 50,
                      child: Text(
                        "Enter your email to reset your password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(
                            255,
                            141,
                            146,
                            161,
                          ).themedWith(isDark),
                          fontFamily: 'Inter_28pt-Regular',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        floatingLabelBehavior: FloatingLabelBehavior.auto,

                        // Change floating label color
                        floatingLabelStyle: TextStyle(
                          color: Colors.blue.themedWith(isDark),
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
                    const SizedBox(height: 15),
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color(
                                    0xFF1E5ED8,
                                  ); // darker blue when pressed
                                }
                                return const Color(
                                  0xFF277AFF,
                                ).themedWith(isDark); // your normal blue
                              }),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 15),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Continue ",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/utils/color_extensions.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final email = ModalRoute.of(context)!.settings.arguments as String?;
    if (email == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error: Email missing")));
      return;
    }

    String enteredOtp = controllers.map((c) => c.text).join();
    if (enteredOtp.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all OTP digits")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('password_reset_otps')
          .doc(email)
          .get();

      if (!doc.exists) {
        throw 'No OTP found for this email. Please try again.';
      }

      final data = doc.data()!;
      final correctOtp = data['otp'];
      final expiresAt = (data['expires_at'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        throw 'OTP has expired. Please request a new one.';
      }

      if (enteredOtp == correctOtp) {
        // 1. Trigger the official Firebase Password Reset Email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        if (!mounted) return;

        // 2. Show Success Message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Identity Verified! A secure reset link has been sent to your email.',
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 5),
          ),
        );

        // 3. Move to Login (Clean Flow)
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        throw 'Invalid OTP. Please check the code and try again.';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
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
                        "Enter OTP",
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
                        "Please enter the OTP sent to your email",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return SizedBox(
                          width: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: TextFormField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "", // hides the default counter
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 223, 227, 230),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF277AFF,
                                    ).themedWith(isDark),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length == 1 && index < 4) {
                                  // move focus to next field
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(focusNodes[index + 1]);
                                }
                                if (value.isEmpty && index > 0) {
                                  // move focus back if deleted
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(focusNodes[index - 1]);
                                }
                              },
                            ),
                          ),
                        );
                      }), // add spacing between fields
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
                                  const Color.fromARGB(
                                    255,
                                    29,
                                    88,
                                    184,
                                  ); // darker green-ish
                                }
                                return const Color(
                                  0xFF277AFF,
                                ).themedWith(isDark); // your normal green
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
                        onPressed: _isLoading ? null : _verifyOtp,
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

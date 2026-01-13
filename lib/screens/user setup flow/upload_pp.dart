import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';

class UploadPPScreen extends StatefulWidget {
  const UploadPPScreen({super.key});
  @override
  State<UploadPPScreen> createState() => _UploadPPScreenState();
}

class _UploadPPScreenState extends State<UploadPPScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  String? _googleProfilePicUrl;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(1.0); // Progress bar at 100%
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await DatabaseService().getUserData();
    if (data != null && data['account_info'] != null) {
      setState(() {
        _googleProfilePicUrl = data['account_info']['profile_picture'];
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
        // Save immediately to matches ProfileScreen behavior
        await DatabaseService().updateProfilePicture(imageFile);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied or error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white.themedWith(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed progress bar at top
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0).themedWith(isDark),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: controller.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          const Color(0xFF3AC0A0).themedWith(isDark),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Scrollable content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Card with form
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFD4D4D4,
                                  ).themedWith(isDark),
                                  width: 1,
                                ),
                              ),
                              color: Colors.white.themedWith(isDark),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF277AFF,
                                                ).themedWith(isDark),
                                                width: 2,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                _selectedImage != null
                                                    ? ClipOval(
                                                        child: Image.file(
                                                          _selectedImage!,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : _googleProfilePicUrl !=
                                                          null
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          _googleProfilePicUrl!,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Icon(
                                                                  Icons.person,
                                                                  size: 75,
                                                                  color: Colors
                                                                      .white
                                                                      .themed(
                                                                        context,
                                                                      ),
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Container(
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              const Color(
                                                                    0xFF277AFF,
                                                                  )
                                                                  .themed(
                                                                    context,
                                                                  )
                                                                  .withValues(
                                                                    alpha: 0.24,
                                                                  ),
                                                        ),
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 75,
                                                          color: Colors.white
                                                              .themedWith(
                                                                isDark,
                                                              ),
                                                        ),
                                                      ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: const Color(
                                                        0xFF277AFF,
                                                      ).themedWith(isDark),
                                                    ),
                                                    child: IconButton(
                                                      onPressed:
                                                          _pickImageFromGallery,
                                                      icon: Icon(
                                                        Icons.camera_alt,
                                                        size: 18,
                                                        color: Colors.white
                                                            .themedWith(isDark),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_selectedImage != null)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: _removeImage,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red.themed(
                                                      context,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color: Colors.white.themed(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Upload Profile Picture (Optional)",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.normal,
                                          color: const Color(
                                            0xFF000000,
                                          ).themedWith(isDark),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Navigation buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return const Color(
                                            0xFFE2E2E2,
                                          ).themedWith(isDark);
                                        }
                                        return Colors.white.themedWith(isDark);
                                      }),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  side: WidgetStateProperty.all(
                                    BorderSide(
                                      color: const Color(
                                        0xFF3AC0A0,
                                      ).themedWith(isDark),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Previous",
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF000000,
                                    ).themedWith(isDark),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Update Firestore
                                    await DatabaseService()
                                        .createOrUpdateUserData({
                                          'setup_complete': true,
                                        });

                                    if (!context.mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/dashboard',
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return const Color(0xFF3AC0A0)
                                              .themedWith(isDark)
                                              .withValues(alpha: 0.8);
                                        }
                                        return const Color(
                                          0xFF3AC0A0,
                                        ).themedWith(isDark);
                                      }),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Save & Continue",
                                  style: TextStyle(
                                    color: Colors.white.themedWith(isDark),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

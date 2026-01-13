import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DashboardMenu extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onClose;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;
  final VoidCallback? onProfileUpdate;

  const DashboardMenu({
    super.key,
    required this.onClose,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePictureUrl,
    this.onProfileUpdate,
  });

  @override
  State<DashboardMenu> createState() => _DashboardMenuState();
}

class _DashboardMenuState extends State<DashboardMenu> {
  String? _currentProfilePic;

  @override
  void initState() {
    super.initState();
    _currentProfilePic = widget.profilePictureUrl;
  }

  @override
  void didUpdateWidget(DashboardMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profilePictureUrl != oldWidget.profilePictureUrl) {
      setState(() {
        _currentProfilePic = widget.profilePictureUrl;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        await DatabaseService().updateProfilePicture(file);
        setState(() {
          _currentProfilePic = image.path;
        });
        if (widget.onProfileUpdate != null) {
          widget.onProfileUpdate!();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      }
    } catch (e) {
      // Error picking image
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 320,
      decoration: BoxDecoration(color: Colors.white.themedWith(isDark)),
      child: Column(
        children: [
          Container(
            height: 194,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 10, 5, 15),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white.themedWith(isDark),
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.themedWith(isDark),
                        size: 28,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.white.themedWith(isDark),
                          ),
                          borderRadius: BorderRadius.circular(10000),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child:
                                _currentProfilePic != null &&
                                    _currentProfilePic!.isNotEmpty
                                ? (_currentProfilePic!.startsWith('http')
                                      ? Image.network(
                                          _currentProfilePic!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_currentProfilePic!),
                                          fit: BoxFit.cover,
                                        ))
                                : Icon(
                                    Icons.person,
                                    color: Colors.black.themedWith(isDark),
                                    size: 35,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          widget.onClose();
                          Navigator.pushNamed(context, '/profile').then((_) {
                            if (widget.onProfileUpdate != null) {
                              widget.onProfileUpdate!();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.firstName} ${widget.lastName}",
                                style: TextStyle(
                                  color: Colors.white.themedWith(isDark),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.email,
                                style: TextStyle(
                                  color: Colors.white.themedWith(isDark),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          _menuItem(
            'moon.svg',
            "Dark Mode",
            color: const Color.fromARGB(255, 94, 94, 94).themedWith(isDark),
            onTap: null, // Dark mode uses the switch only
            context: context,
          ),
          const SizedBox(height: 5),

          _menuItem(
            "filetext.svg",
            "Export Health Data",
            color: const Color.fromARGB(255, 94, 94, 94).themedWith(isDark),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Preparing your health report..."),
                    duration: Duration(seconds: 2),
                  ),
                );
                final path = await DatabaseService().exportHealthData();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Exported to: $path"),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(label: 'OK', onPressed: () {}),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Export failed: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            context: context,
          ),
          const SizedBox(height: 10),

          _menuItem(
            "alertcircle-icon.svg",
            "Help & Support",
            color: const Color.fromARGB(255, 94, 94, 94).themedWith(isDark),
            onTap: () {
              _showHelpDialog(context);
            },
            context: context,
          ),
          const SizedBox(height: 10),

          _menuItem(
            "logout.svg",
            "Logout",
            color: Colors.red.themedWith(isDark),
            onTap: () {
              AuthService().signOut(context);
            },
            context: context,
          ),
          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            height: 0.5,
            padding: const EdgeInsets.symmetric(vertical: 5),
            color: const Color.fromARGB(96, 131, 131, 131).themedWith(isDark),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  "MedVault v1.0.0",
                  style: TextStyle(
                    color: Colors.grey.themedWith(isDark),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your health, secure & organized",
                  style: TextStyle(
                    color: Colors.grey.themedWith(isDark),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.themedWith(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Help & Support",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: const Color(0xFF277AFF).themedWith(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              context,
              Icons.email_outlined,
              "support@medvault.com",
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              context,
              Icons.language_outlined,
              "www.medvault.com",
            ),
            const SizedBox(height: 12),
            _buildHelpItem(context, Icons.info_outline, "Version 1.0.0"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(
                color: const Color(0xFF277AFF).themedWith(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, IconData icon, String text) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF277AFF).themedWith(isDark)),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: const Color(0xFF2B2F33).themedWith(isDark),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(
    String name,
    String text, {
    required VoidCallback? onTap,
    required BuildContext context,
    Color? color,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ?? const Color.fromARGB(255, 94, 94, 94).themedWith(isDark);
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 20, 15, 0),
        child: InkWell(
          onTap: text == "Dark Mode" ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/icon for Medvault/$name",
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(
                    name == "logout.svg"
                        ? Colors.red.themedWith(isDark)
                        : effectiveColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    color: effectiveColor,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 50),
                if (text == "Dark Mode")
                  Switch(
                    value: widget.isDarkMode,
                    onChanged: widget.onDarkModeChanged,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    trackColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      return states.contains(WidgetState.selected)
                          ? const Color(0xFF277AFF).themedWith(
                              isDark,
                            ) // Brand Blue
                          : const Color(0xFFB0B4B8).themedWith(isDark);
                    }),
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

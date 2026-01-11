import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/auth_service.dart';

class DashboardMenu extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onClose;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;

  const DashboardMenu({
    super.key,
    required this.onClose,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePictureUrl,
  });
  // callback for close butto
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(color: Colors.white.themed(context)),
      child: Column(
        children: [
          Container(
            height: 194,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 10, 5, 15),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themed(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white.themed(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.themed(context),
                        size: 28,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.themed(context),
                      backgroundImage:
                          profilePictureUrl != null &&
                              profilePictureUrl!.isNotEmpty
                          ? NetworkImage(profilePictureUrl!)
                          : null,
                      child:
                          profilePictureUrl == null ||
                              profilePictureUrl!.isEmpty
                          ? Icon(
                              Icons.person,
                              color: Colors.black.themed(context),
                              size: 35,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "$firstName $lastName\n",
                              style: TextStyle(
                                color: Colors.white.themed(context),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                color: Colors.white.themed(context),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
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
            color: const Color.fromARGB(255, 94, 94, 94).themed(context),
            onTap: null, // Dark mode uses the switch only
            context: context,
          ),
          const SizedBox(height: 5),

          _menuItem(
            "cloud.svg",
            "Backup & sync",
            color: const Color.fromARGB(255, 94, 94, 94).themed(context),
            onTap: () {},
            context: context,
          ),
          const SizedBox(height: 10),

          _menuItem(
            "shield.svg",
            "Privacy & security",
            color: const Color.fromARGB(255, 94, 94, 94).themed(context),
            onTap: () {},
            context: context,
          ),
          const SizedBox(height: 10),

          _menuItem(
            "logout.svg",
            "Logout",
            color: Colors.red.themed(context),
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
            color: const Color.fromARGB(96, 131, 131, 131).themed(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  "MedVault v1.0.0",
                  style: TextStyle(
                    color: Colors.grey.themed(context),
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your health, secure & organized",
                  style: TextStyle(
                    color: Colors.grey.themed(context),
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

  Widget _menuItem(
    String name,
    String text, {
    required VoidCallback? onTap,
    required BuildContext context,
    Color? color,
  }) {
    final effectiveColor =
        color ?? const Color.fromARGB(255, 94, 94, 94).themed(context);
    return Material(
      // <-- This makes InkWell effects visible
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
                        ? Colors.red.themed(context)
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

                // Switch for Dark Mode
                if (text == "Dark Mode")
                  Switch(
                    value: isDarkMode,
                    onChanged: onDarkModeChanged,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    trackColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      return states.contains(WidgetState.selected)
                          ? const Color(0xFF277AFF).themed(
                              context,
                            ) // Brand Blue
                          : const Color(0xFFB0B4B8).themed(context);
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

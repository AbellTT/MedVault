import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';

class DashboardNavigationBar extends StatefulWidget {
  final int selectedIndex; // pass current index
  final VoidCallback? onReturn;
  const DashboardNavigationBar({
    super.key,
    required this.selectedIndex,
    this.onReturn,
  });
  @override
  State<DashboardNavigationBar> createState() => _DashboardNavigationBarState();
}

class _DashboardNavigationBarState extends State<DashboardNavigationBar> {
  // Home is selected by default
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex; // initialize from widget
  }

  void _onItemTapped(int index) {
    if (index == selectedIndex) return;
    // Handle navigation here based on index
    // You can use Navigator.push or any state management solution
    switch (index) {
      case 0:
        {
          Navigator.pushNamed(context, '/appointmentsDashboard');
          break;
        }
      case 1:
        {
          Navigator.pushNamed(context, '/medsDashboard');
          break;
        }
      case 2:
        {
          Navigator.pushNamed(context, '/dashboard');
          break;
        }
      case 4:
        {
          Navigator.pushNamed(context, '/profile').then((_) {
            if (widget.onReturn != null) widget.onReturn!();
          });
          break;
        }
      case 3:
        {
          Navigator.pushNamed(context, '/diagnosisDashboard');
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Widget navItem(String asset, int index) {
      final bool isSelected = selectedIndex == index;
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BLUE TOP BORDER WHEN SELECTED
          Transform.translate(
            offset: const Offset(0, -5), // Shift the blue bar up
            child: Container(
              height: 3,
              width: 55,
              decoration: BoxDecoration(
                color:
                    (isSelected ? const Color(0xFF277AFF) : Colors.transparent)
                        .themedWith(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // SVG ICON WITH COLOR DEPENDING ON SELECTION
          SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              (isSelected ? const Color(0xFF277AFF) : const Color(0xFF6C7278))
                  .themedWith(isDark),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 5),
        ],
      );
    }

    return SizedBox(
      height: 90, // 👈 change height here
      // optional
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(
            0xFF277AFF,
          ).themedWith(isDark), // Blue color for selected item
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 8,
          backgroundColor: Colors.white.themedWith(isDark),
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C7278).themedWith(isDark),
            fontSize: 10,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278).themedWith(isDark),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: navItem('assets/images/icon for Medvault/calendar.svg', 0),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: navItem('assets/images/icon for Medvault/pill.svg', 1),
              label: 'Meds',
            ),
            BottomNavigationBarItem(
              icon: navItem('assets/images/icon for Medvault/home.svg', 2),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: navItem('assets/images/icon for Medvault/activity.svg', 3),
              label: 'Diagnosis',
            ),
            BottomNavigationBarItem(
              icon: navItem('assets/images/icon for Medvault/user.svg', 4),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

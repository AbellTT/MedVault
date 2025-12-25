# Dark Mode Implementation Guide for MedVault

## What is Dark Mode?

Dark mode changes your app's colors from light (white backgrounds) to dark (dark blue/gray backgrounds). It's easier on the eyes at night and saves battery on OLED screens.

---

## How Dark Mode Works in Your App

### 1. The Dark Mode Button (Dashboard Menu)

**Location:** `lib/screens/dashboard flow/dashboard_menu.dart`

```dart
// This is the toggle switch in your menu
Switch(
  value: isDarkMode,  // ← Is dark mode ON or OFF?
  onChanged: onDarkModeChanged,  // ← What happens when user toggles?
)
```

**How it works:**

- When user flips the switch, `onDarkModeChanged` function runs
- This function is passed from `main.dart`
- It updates the `isDarkMode` variable in `main.dart`

---

### 2. Theme System (main.dart)

**Location:** `lib/main.dart`

Your app has TWO themes defined:

```dart
class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;  // ← Starts in light mode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,  // ← Chooses theme

      // LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,  // ← Light mode background
        // ... more light colors
      ),

      // DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF152034),  // ← Dark mode background
        // ... more dark colors
      ),
    );
  }
}
```

**The Problem:**
Even though you HAVE dark theme defined, **screens don't use it!** They have hardcoded colors like `Colors.white` instead of using the theme.

---

## Step-by-Step Implementation Plan

### Step 1: Save User's Preference (So it remembers)

Right now, when you close the app, dark mode resets. We need to **save** it.

#### 1.1 Add SharedPreferences Package

**File:** `pubspec.yaml`

Add this line under `dependencies:`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.7
  shared_preferences: ^2.2.2 # ← ADD THIS LINE
```

Then run in terminal:

```
flutter pub get
```

#### 1.2 Create Theme Service

**File:** `lib/services/theme_service.dart` (CREATE NEW FILE)

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // This is the "key" to find dark mode setting in storage
  static const String _isDarkModeKey = 'isDarkMode';

  // SAVE dark mode setting
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
  }

  // LOAD dark mode setting
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;  // Default is light mode
  }
}
```

**What this does:**

- `saveDarkMode` = Saves true/false to phone storage
- `loadDarkMode` = Reads true/false from phone storage
- `?? false` = If nothing saved yet, use light mode

#### 1.3 Update main.dart to Use Theme Service

**File:** `lib/main.dart`

Add import at top:

```dart
import 'package:app/services/theme_service.dart';
```

Update `_MyAppState` class:

```dart
class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  // LOAD setting when app starts
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedDarkMode = await ThemeService.loadDarkMode();
    setState(() {
      isDarkMode = savedDarkMode;
    });
  }

  // SAVE setting when user toggles
  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    ThemeService.saveDarkMode(value);  // ← SAVE IT!
  }

  // ... rest of code
}
```

---

### Step 2: Create Color System

Instead of hardcoding `Colors.white` everywhere, we create a **color helper** that knows which color to use.

#### 2.1 Create AppColors Class

**File:** `lib/theme/app_colors.dart` (CREATE NEW FILE)

```dart
import 'package:flutter/material.dart';

class AppColors {
  final bool isDarkMode;

  AppColors({required this.isDarkMode});

  // BACKGROUNDS
  Color get scaffoldBackground => isDarkMode
    ? const Color(0xFF152034)  // Dark blue-gray
    : Colors.white;

  Color get cardBackground => isDarkMode
    ? const Color(0xFF1E2A42)  // Slightly lighter than scaffold
    : Colors.white;

  Color get inputBackground => isDarkMode
    ? const Color(0xFF1E2A42)
    : const Color(0xFFF5F5F5);  // Light gray

  // TEXT COLORS
  Color get primaryText => isDarkMode
    ? Colors.white
    : const Color(0xFF2B2F33);  // Dark gray

  Color get secondaryText => isDarkMode
    ? Colors.white70
    : const Color(0xFF6C7278);  // Gray

  // BORDERS
  Color get borderColor => isDarkMode
    ? const Color(0xFF3A4A62)  // Visible on dark background
    : const Color.fromARGB(178, 212, 212, 212);  // Light gray

  Color get inputBorder => isDarkMode
    ? const Color(0xFF3A4A62)
    : const Color(0xFFE0E0E0);

  // BRAND COLORS (NEVER CHANGE THESE!)
  Color get primaryBlue => const Color(0xFF277AFF);  // Always blue
  Color get tealAccent => const Color(0xFF3AC0A0);   // Always teal

  // STATUS COLORS - For diagnosis/medication badges
  // Ongoing status
  Color get ongoingBackground => isDarkMode
    ? const Color.fromARGB(80, 255, 179, 77)  // Darker orange background
    : const Color(0xFFFFE7CD);  // Light orange

  Color get ongoingText => isDarkMode
    ? const Color(0xFFFFAA44)  // Lighter orange text
    : const Color(0xFFCC8400);  // Dark orange

  // Managed status
  Color get managedBackground => isDarkMode
    ? const Color.fromARGB(80, 129, 199, 132)  // Darker green background
    : const Color.fromARGB(118, 232, 255, 241);  // Light green

  Color get managedText => isDarkMode
    ? const Color(0xFF81C784)  // Lighter green text
    : const Color(0xFF4CAF50);  // Dark green
}
```

---

### Step 3: Pass AppColors to All Screens

We need a way for EVERY screen to access `appColors`. Use **InheritedWidget**.

#### 3.1 Create Theme Provider

**File:** `lib/theme/theme_provider.dart` (CREATE NEW FILE)

```dart
import 'package:flutter/material.dart';
import 'package:app/theme/app_colors.dart';

// This "wraps" your whole app and provides appColors everywhere
class ThemeProvider extends InheritedWidget {
  final AppColors appColors;
  final bool isDarkMode;

  const ThemeProvider({
    super.key,
    required this.appColors,
    required this.isDarkMode,
    required super.child,
  });

  // This lets any screen get appColors
  static ThemeProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
```

#### 3.2 Update main.dart to Wrap App

**File:** `lib/main.dart`

Add imports:

```dart
import 'package:app/theme/app_colors.dart';
import 'package:app/theme/theme_provider.dart';
```

Update`build` method:

```dart
@override
Widget build(BuildContext context) {
  return ThemeProvider(  // ← WRAP MaterialApp
    appColors: AppColors(isDarkMode: isDarkMode),
    isDarkMode: isDarkMode,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // ... rest of MaterialApp code
    ),
  );
}
```

---

### Step 4: Update Screens (Example)

Now ANY screen can access colors using `ThemeProvider.of(context).appColors`.

**Example:** Update Dashboard Screen

**File:** `lib/screens/dashboard flow/dashboard_screen.dart`

**BEFORE (hardcoded):**

```dart
return Scaffold(
  backgroundColor: Colors.white,  // ← HARDCODED
  // ...
);
```

**AFTER (dynamic):**

```dart
@override
Widget build(BuildContext context) {
  final appColors = ThemeProvider.of(context).appColors;  // ← GET COLORS

  return Scaffold(
    backgroundColor: appColors.scaffoldBackground,  // ← DYNAMIC!
    // ...
  );
}
```

**More replacements in same file:**

```dart
// Card background
Card(
  color: appColors.cardBackground,  // Instead of: Colors.white
  // ...
)

// Text colors
Text(
  'Dashboard',
  style: TextStyle(
    color: appColors.primaryText,  // Instead of: Color(0xFF2B2F33)
  ),
)

// Border colors
border: Border.all(
  color: appColors.borderColor,  // Instead of: Color.fromARGB(178, 212, 212, 212)
)
```

---

## Color Replacement Cheat Sheet

| What to Replace                             | Replace With                                           |
| ------------------------------------------- | ------------------------------------------------------ |
| `backgroundColor: Colors.white`             | `backgroundColor: appColors.scaffoldBackground`        |
| `color: Colors.white` (cards)               | `color: appColors.cardBackground`                      |
| `color: Color(0xFF2B2F33)` (dark text)      | `color: appColors.primaryText`                         |
| `color: Color(0xFF6C7278)` (gray text)      | `color: appColors.secondaryText`                       |
| `fillColor: Color(0xFFF5F5F5)` (inputs)     | `fillColor: appColors.inputBackground`                 |
| `borderSide: BorderSide(color: Color(...))` | `borderSide: BorderSide(color: appColors.borderColor)` |

**DON'T CHANGE:**

- `Color(0xFF277AFF)` - Keep blue headers
- `Color(0xFF3AC0A0)` - Keep teal accent
- `Colors.red` - Keep error colors

---

## Testing Your Implementation

1. **Test toggle:**

   - Open app
   - Go to Dashboard → Click menu → Toggle dark mode
   - All screens should change colors

2. **Test persistence:**

   - Toggle dark mode ON
   - Close app completely
   - Reopen app
   - Should still be in dark mode

3. **Test all screens:**
   - Navigate to every screen
   - Check text is readable
   - Check borders are visible

---

## Screen Update Checklist

For EACH screen file, do this:

1. ✅ Add at top of `build` method:

   ```dart
   final appColors = ThemeProvider.of(context).appColors;
   ```

2. ✅ Replace scaffold background:

   ```dart
   backgroundColor: appColors.scaffoldBackground,
   ```

3. ✅ Replace all card backgrounds:

   ```dart
   color: appColors.cardBackground,
   ```

4. ✅ Replace all text colors:

   - Dark text → `appColors.primaryText`
   - Gray text → `appColors.secondaryText`

5. ✅ Replace all border colors:

   ```dart
   borderSide: BorderSide(color: appColors.borderColor)
   ```

6. ✅ Replace input field colors:

   ```dart
   fillColor: appColors.inputBackground,
   ```

7. ✅ Test in both light and dark mode

---

## All Screens to Update (28 total)

### Dashboard (3 files)

- [ ] `dashboard_screen.dart`
- [ ] `dashboard_menu.dart`
- [ ] `dashboard_nav_bar.dart`

### Authentication (6 files)

- [ ] `splash_screen.dart`
- [ ] `login_screen.dart`
- [ ] `signup_screen.dart`
- [ ] `forgot_password_screen.dart`
- [ ] `enter_otp_screen.dart`
- [ ] `reset_password_screen.dart`

### User Setup (6 files)

- [ ] `get_started_screen.dart`
- [ ] `personal_info_screen.dart`
- [ ] `health_metrics.dart`
- [ ] `emergency_contact.dart`
- [ ] `medical_info.dart`
- [ ] `upload_pp.dart`

### Appointments (4 files)

- [ ] `appointments_dashboard.dart`
- [ ] `add_appointment.dart`
- [ ] `appointment_detail.dart`
- [ ] `appointment_edit.dart`

### Medications (5 files)

- [ ] `meds_dashboard.dart`
- [ ] `add_medicine.dart`
- [ ] `med_detail.dart`
- [ ] `med_detailedit.dart`
- [ ] `med_reminders.dart`

### Diagnosis (3 files)

- [ ] `diagnosis_dashBoard.dart`
- [ ] `add_diagnosis.dart`
- [ ] `diagnosis_detail.dart`

### Profile (1 file)

- [ ] `profile_screen.dart`

---

## Common Questions

**Q: Why not just use Theme.of(context)?**
A: Flutter's built-in theme doesn't give enough control over individual colors. Our `AppColors` system is more flexible.

**Q: What if colors look bad in dark mode?**
A: Edit `app_colors.dart` and adjust the dark mode colors until they look good.

**Q: Do I have to update all 28 screens at once?**
A: No! Update screen by screen. Start with dashboard, test, then move to next screen.

**Q: Will this slow down my app?**
A: No. The color lookup is very fast. No performance impact.

---

## Summary

1. ✅ Add `shared_preferences` package
2. ✅ Create `ThemeService` to save/load preference
3. ✅ Create `AppColors` with all color definitions
4. ✅ Create `ThemeProvider` to share colors
5. ✅ Update `main.dart` to use provider
6. ✅ Update each screen to use `appColors`
7. ✅ Test toggle and persistence

Good luck! 🚀

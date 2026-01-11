import 'package:flutter/material.dart';

extension ThemeColor on Color {
  Color themed(BuildContext context) {
    return themedWith(Theme.of(context).brightness == Brightness.dark);
  }

  Color themedWith(bool isDark) {
    if (!isDark) return this;

    // Use RGB values for comparison (ignore alpha)
    final int rgbValue = toARGB32() & 0x00FFFFFF;

    // Backgrounds & Surfaces
    if (rgbValue == 0xFFFFFF) {
      return const Color(0xFF0A1220).withValues(alpha: a);
    }
    if (rgbValue == 0xF7F8FA) {
      return const Color(0xFF152034).withValues(alpha: a);
    }
    if (rgbValue == 0xE8F5F1) {
      return const Color(0xFF1A3A34).withValues(alpha: a);
    }
    if (rgbValue == 0xE8F1FF || rgbValue == 0xF0F4FF || rgbValue == 0xF5F9FF) {
      return const Color(0xFF1E293B).withValues(alpha: a);
    }

    // Diagnosis Status Backgrounds (Tints)
    if (rgbValue == 0xFFE7CD || rgbValue == 0xFFF3D8) {
      return const Color(0xFF3B2A1A).withValues(alpha: a); // Orange Tint
    }
    if (rgbValue == 0xFFCDD2 ||
        rgbValue == 0xFFFFEBEE ||
        rgbValue == 0xFFEBEE) {
      return const Color(0xFF3B1A1A).withValues(alpha: a * 0.60); // Red Tint
    }
    if (rgbValue == 0xFFF9C4) {
      return const Color(0xFF3B381A).withValues(alpha: a); // Yellow Tint
    }
    if (rgbValue == 0xE8FFF1 || rgbValue == 0xE8F1EE || rgbValue == 0xE8FFF1) {
      return const Color(0xFF1A3A2A).withValues(alpha: a); // Green Tint
    }
    if (rgbValue == 0xFFF9E6) {
      return const Color(0xFF3B381A).withValues(alpha: a * 0.60); // Yellow Tint
    }
    if (rgbValue == 0xFBC02D) {
      return const Color(0xFFFBC02D).withValues(
        alpha: 0.9,
      ); // Keep yellow but slightly dimmed if needed, or just return itself.
    }
    if (rgbValue == 0xF3E8FF) {
      return const Color(0xFF2D2040).withValues(alpha: a * 0.65); // Purple Tint
    }
    if (rgbValue == 0xE8F5E9) {
      return const Color(
        0xFF1A3A2A,
      ).withValues(alpha: a * 0.60); // Green Tint for Meds Dashboard
    }
    if (rgbValue == 0xF5F5F5) {
      return const Color(0xFF152034).withValues(alpha: a * 0.60);
    }
    if (rgbValue == 0xE3F2FD) {
      return const Color(
        0xFF1E293B,
      ).withValues(alpha: a * 0.60); // Blue Tint for Reminders
    }

    // Text & Content - Secondary & Misc Greys
    if (rgbValue == 0x2B2F33 || rgbValue == 0x1A1A1A || rgbValue == 0x000000) {
      return const Color(0xFFEBF2FF).withValues(alpha: a);
    }
    if (rgbValue == 0x6C7278 ||
        rgbValue == 0x60666B ||
        rgbValue == 0x585C61 ||
        rgbValue == 0x61677D ||
        rgbValue == 0x8D92A1 ||
        rgbValue == 0x5F5D5D ||
        rgbValue == 0x5E5E5E ||
        rgbValue == 0x595959 ||
        rgbValue == 0x666666 ||
        rgbValue == 0x2C2C2C) {
      return const Color(0xFFA0AEC0).withValues(alpha: a);
    }

    // Material Greys
    if (rgbValue == 0x9E9E9E) {
      return const Color(0xFFA0AEC0).withValues(alpha: a); // Colors.grey
    }
    if (rgbValue == 0x757575) {
      return const Color(0xFF8A94AD).withValues(alpha: a); // Colors.grey[600]
    }

    // Borders & Dividers
    if (rgbValue == 0xD4D4D4 ||
        rgbValue == 0xE2E4E8 ||
        rgbValue == 0xE5E7EB ||
        rgbValue == 0xDFE3E6 ||
        rgbValue == 0xE0E0E0) {
      return const Color(0xFF2D3748).withValues(alpha: a);
    }
    if (rgbValue == 0xB0B4B8) {
      return const Color(0xFF718096).withValues(alpha: a);
    }

    // Visibility boost: If opacity is very low (< 10%), boost it for dark mode surfaces
    if (a > 0 && a < 0.1) {
      return withValues(alpha: 0.15); // Make it clearly visible
    }

    // Brand Colors - Slightly darker/less saturated in dark mode for better aesthetics
    if (rgbValue == 0x3AC0A0) {
      return const Color(0xFF27A384); // Brand Green (Darker)
    }
    if (rgbValue == 0x277AFF) {
      return const Color(0xFF1E6AD4); // Primary Blue (Darker)
    }

    return this;
  }
}

import 'package:flutter/material.dart';

class MedicationReminder {
  final String medicationName;
  final String dosage;
  final TimeOfDay time;
  final bool isCompleted;

  MedicationReminder({
    required this.medicationName,
    required this.dosage,
    required this.time,
    this.isCompleted = false,
  });

  String formatTime(BuildContext context) {
    return time.format(context);
  }

  Color get backgroundColor {
    if (isCompleted) {
      return const Color.fromARGB(130, 232, 255, 240);
    }
    return const Color.fromARGB(204, 231, 238, 255);
  }

  Color get borderColor {
    if (isCompleted) {
      return const Color.fromARGB(86, 58, 192, 161);
    }
    return const Color.fromARGB(85, 58, 116, 192);
  }

  String get iconAsset {
    if (isCompleted) {
      return "assets/images/icon for Medvault/checkcircle2.svg";
    }
    return "assets/images/icon for Medvault/pill.svg";
  }

  Color get iconBackgroundColor {
    if (isCompleted) {
      return const Color.fromARGB(80, 135, 230, 174);
    }
    return const Color.fromARGB(80, 135, 174, 230);
  }

  Color get iconColor {
    if (isCompleted) {
      return const Color(0xFF3AC0A0);
    }
    return const Color(0xFF277AFF);
  }

  Color get textColor {
    if (isCompleted) {
      return Colors.grey;
    }
    return const Color(0xFF2B2F33);
  }
}

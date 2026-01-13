import 'package:flutter/material.dart';

enum DiagnosisStatus { ongoing, recurring, resolved }

class Diagnosis {
  final String name;
  final DateTime diagnosedDate;
  final DiagnosisStatus status;

  Diagnosis({
    required this.name,
    required this.diagnosedDate,
    required this.status,
  });

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[diagnosedDate.month - 1]} ${diagnosedDate.year}';
  }

  String get statusText {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return 'Ongoing';
      case DiagnosisStatus.recurring:
        return 'Recurring';
      case DiagnosisStatus.resolved:
        return 'Resolved';
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return const Color(0xFFFFE7CD);
      case DiagnosisStatus.recurring:
        return const Color.fromARGB(255, 255, 251, 205);
      case DiagnosisStatus.resolved:
        return const Color.fromARGB(255, 205, 255, 216);
    }
  }

  Color get statusBorderColor {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return const Color.fromARGB(40, 162, 124, 0);
      case DiagnosisStatus.recurring:
        return const Color.fromARGB(40, 162, 157, 0);
      case DiagnosisStatus.resolved:
        return const Color.fromARGB(40, 0, 162, 68);
    }
  }

  Color get statusTextColor {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return const Color(0xFFCC8400);
      case DiagnosisStatus.recurring:
        return const Color.fromARGB(255, 174, 161, 40);
      case DiagnosisStatus.resolved:
        return const Color.fromARGB(255, 40, 174, 68);
    }
  }
}

import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String location;
  final String reason;
  final String notes;
  final String linkedDiagnosis;
  final String status;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.location,
    this.reason = '',
    this.notes = '',
    required this.linkedDiagnosis,
    this.status = 'Upcoming',
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatTime(BuildContext? context) {
    if (context == null) {
      final period = startTime.hour >= 12 ? 'PM' : 'AM';
      // Basic 12h format for notifications
      int h12 = startTime.hour % 12;
      if (h12 == 0) h12 = 12;
      return '$h12:${startTime.minute.toString().padLeft(2, '0')} $period';
    }
    String time = startTime.format(context);
    if (endTime != null) {
      time += ' - ${endTime!.format(context)}';
    }
    return time;
  }
}

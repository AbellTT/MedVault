import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum DiagnosisStatus { ongoing, managed, recurring, resolved }

enum DiagnosisSeverity { low, moderate, high }

class DiagnosisItem {
  final String id;
  final String title;
  final String description;
  final DiagnosisStatus status;
  final DiagnosisSeverity severity;
  final DateTime diagnosedDate;
  final int documentsCount;
  final int medicationsCount;

  DiagnosisItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.severity,
    required this.diagnosedDate,
    required this.documentsCount,
    required this.medicationsCount,
  });

  factory DiagnosisItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle Status with fallback to 'ongoing'
    DiagnosisStatus parseStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'managed':
          return DiagnosisStatus.managed;
        case 'recurring':
          return DiagnosisStatus.recurring;
        case 'resolved':
          return DiagnosisStatus.resolved;
        default:
          return DiagnosisStatus.ongoing;
      }
    }

    // Handle Severity with fallback to 'low'
    DiagnosisSeverity parseSeverity(String? severity) {
      switch (severity?.toLowerCase()) {
        case 'moderate':
          return DiagnosisSeverity.moderate;
        case 'high':
          return DiagnosisSeverity.high;
        default:
          return DiagnosisSeverity.low;
      }
    }

    return DiagnosisItem(
      id: doc.id,
      title: data['name'] ?? 'Unknown Diagnosis',
      description: data['description'] ?? 'No description provided.',
      status: parseStatus(data['status']),
      severity: parseSeverity(data['severity']),
      diagnosedDate:
          (data['diagnosed_date'] as Timestamp?)?.toDate() ??
          (data['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      documentsCount: data['documents_count'] ?? 0,
      medicationsCount: data['medications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': title,
      'description': description,
      'status': status.name,
      'severity': severity.name,
      'diagnosed_date': Timestamp.fromDate(diagnosedDate),
      'documents_count': documentsCount,
      'medications_count': medicationsCount,
      'updated_at': FieldValue.serverTimestamp(),
      'created_at':
          FieldValue.serverTimestamp(), // Firestore will ignore this during merge if it exists? No, it will overwrite it.
    };
  }

  // Helper: Get status display text
  String get statusText {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return 'Ongoing';
      case DiagnosisStatus.managed:
        return 'Managed';
      case DiagnosisStatus.recurring:
        return 'Recurring';
      case DiagnosisStatus.resolved:
        return 'Resolved';
    }
  }

  // Helper: Get status colors
  Color get statusBackgroundColor {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return const Color(0xFFFFE7CD); // Light orange
      case DiagnosisStatus.managed:
        return const Color(0xFFFFCDD2); // Light red/pink
      case DiagnosisStatus.recurring:
        return const Color(0xFFFFF9C4); // Light yellow
      case DiagnosisStatus.resolved:
        return const Color.fromARGB(118, 232, 255, 241); // Light green
    }
  }

  Color get statusTextColor {
    switch (status) {
      case DiagnosisStatus.ongoing:
        return const Color(0xFFCC8400); // Dark orange
      case DiagnosisStatus.managed:
        return const Color(0xFFD32F2F); // Dark red
      case DiagnosisStatus.recurring:
        return const Color.fromARGB(255, 174, 161, 40); // Dark yellow
      case DiagnosisStatus.resolved:
        return const Color(0xFF4CAF50); // Dark green
    }
  }

  Color get statusBorderColor {
    return statusTextColor.withAlpha(40);
  }

  // Helper: Get severity display text
  String get severityText {
    switch (severity) {
      case DiagnosisSeverity.low:
        return 'Low';
      case DiagnosisSeverity.moderate:
        return 'Moderate';
      case DiagnosisSeverity.high:
        return 'High';
    }
  }

  // Helper: Get severity color
  Color get severityColor {
    switch (severity) {
      case DiagnosisSeverity.low:
        return const Color(0xFFFBC02D); // Yellow
      case DiagnosisSeverity.moderate:
        return const Color(0xFFFF9800); // Orange
      case DiagnosisSeverity.high:
        return const Color(0xFFD32F2F); // Red
    }
  }

  // Helper: Format date
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
    return '${months[diagnosedDate.month - 1]} ${diagnosedDate.day}, ${diagnosedDate.year}';
  }

  // Helper: Format documents count
  String get formattedDocsCount =>
      '$documentsCount doc${documentsCount == 1 ? '' : 's'}';

  // Helper: Format medications count
  String get formattedMedsCount =>
      '$medicationsCount med${medicationsCount == 1 ? '' : 's'}';
}

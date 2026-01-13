import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final String prescribedBy;
  final String prescribedDate;
  final String pharmacy;
  final int refillsRemaining;
  final String expiryDate;
  final String notes;
  final String? diagnosisId; // "General" or specific diagnosis document ID
  final bool enableReminders;
  final List<String> reminderTimes; // "HH:mm" format
  final bool isCompleted;
  final DateTime? createdAt;
  final Map<String, List<String>>
  takenDoses; // Date string ("yyyy-MM-dd") -> List of reminder times ("HH:mm")

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.instructions = '',
    this.prescribedBy = '',
    this.prescribedDate = '',
    this.pharmacy = '',
    this.refillsRemaining = 0,
    this.expiryDate = '',
    this.notes = '',
    this.diagnosisId,
    this.enableReminders = false,
    this.reminderTimes = const [],
    this.isCompleted = false,
    this.createdAt,
    this.takenDoses = const {},
  });

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      instructions: data['instructions'] ?? '',
      prescribedBy: data['prescribed_by'] ?? '',
      prescribedDate: data['prescribed_date'] ?? '',
      pharmacy: data['pharmacy'] ?? '',
      refillsRemaining: data['refills_remaining'] ?? 0,
      expiryDate: data['expiry_date'] ?? '',
      notes: data['notes'] ?? '',
      diagnosisId: data['diagnosis_id'],
      enableReminders: data['enable_reminders'] ?? false,
      reminderTimes: List<String>.from(data['reminder_times'] ?? []),
      isCompleted: data['is_completed'] ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      takenDoses:
          (data['taken_doses'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'prescribed_by': prescribedBy,
      'prescribed_date': prescribedDate,
      'pharmacy': pharmacy,
      'refills_remaining': refillsRemaining,
      'expiry_date': expiryDate,
      'notes': notes,
      'diagnosis_id': diagnosisId,
      'enable_reminders': enableReminders,
      'reminder_times': reminderTimes,
      'is_completed': isCompleted,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'taken_doses': takenDoses,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/models/medication.dart';
import 'package:app/models/appointment.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/services/alarm_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Static cache to store user data in memory
  static Map<String, dynamic>? _cachedUserData;
  static List<DiagnosisItem>? _cachedDiagnoses;
  static List<Medication>? _cachedMedications;
  static List<Appointment>? _cachedAppointments;

  static Map<String, dynamic>? get cachedUserData => _cachedUserData;
  static List<DiagnosisItem>? get cachedDiagnoses => _cachedDiagnoses;
  static List<Medication>? get cachedMedications => _cachedMedications;
  static List<Appointment>? get cachedAppointments => _cachedAppointments;

  // Gets the current logged-in user's ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Reusable function to save data to the user's specific document with deep merging
  Future<void> createOrUpdateUserData(Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;

    // Flatten the map to support deep merging of nested fields in Firestore
    final flatData = _flatten(data);

    await _db
        .collection('users')
        .doc(uid)
        .set(flatData, SetOptions(merge: true));

    // Clear cache to force refresh on next fetch
    _cachedUserData = null;
  }

  /// Helper to flatten a nested map into dot-notation (e.g., {"a": {"b": 1}} -> {"a.b": 1})
  Map<String, dynamic> _flatten(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map) {
        result.addAll(_flatten(Map<String, dynamic>.from(value), newKey));
      } else {
        result[newKey] = value;
      }
    });
    return result;
  }

  /// Update the user's profile picture by copying it to a permanent local directory
  Future<void> updateProfilePicture(File image) async {
    final uid = currentUid;
    if (uid == null) return;

    try {
      // 1. Get Application Directory
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/medvault/profile');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // 2. Define path and copy file
      final fileName = 'profile_$uid.${image.path.split('.').last}';
      final localPath = '${profileDir.path}/$fileName';
      await image.copy(localPath);

      // 3. Store path in Firestore using dot notation to avoid overwriting account_info map
      await _db.collection('users').doc(uid).update({
        'account_info.profile_picture': localPath,
      });

      // Clear cache
      _cachedUserData = null;
    } catch (e) {
      rethrow;
    }
  }

  // Reusable function to fetch user data with caching
  Future<Map<String, dynamic>?> getUserData({bool forceRefresh = false}) async {
    if (_cachedUserData != null && !forceRefresh) {
      return _cachedUserData;
    }

    final uid = currentUid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    _cachedUserData = doc.data();
    return _cachedUserData;
  }

  /// Exports all health data to a structured local folder
  Future<String> exportHealthData() async {
    final uid = currentUid;
    if (uid == null) throw Exception('User not logged in');

    try {
      // 1. Prepare Export Directory
      Directory? baseDir;
      if (Platform.isAndroid) {
        // Try Downloads folder on Android for easy access
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
          baseDir = await getExternalStorageDirectory();
        }
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      if (baseDir == null) throw Exception('Could not access storage');

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final exportDir = Directory('${baseDir.path}/MedVault_Export_$timestamp');
      await exportDir.create(recursive: true);

      // 2. Fetch all data
      final userData = await getUserData(forceRefresh: true);
      final diagnoses = await getDiagnoses(forceRefresh: true);
      final medications = await getAllUserMedications(forceRefresh: true);
      final appointments = await getAppointments(forceRefresh: true);

      Map<String, dynamic> exportSummary = {
        'export_date': timestamp,
        'user_info': userData,
        'diagnoses_count': diagnoses.length,
        'medications_count': medications.length,
        'appointments_count': appointments.length,
        'data': {
          'diagnoses': diagnoses.map((d) => d.toFirestore()).toList(),
          'medications': medications.map((m) => m.toFirestore()).toList(),
          'appointments': appointments
              .map(
                (a) => {
                  'doctorName': a.doctorName,
                  'specialty': a.specialty,
                  'date': a.date.toIso8601String(),
                  'location': a.location,
                  'reason': a.reason,
                  'status': a.status,
                },
              )
              .toList(),
        },
      };

      // 3. Process Diagnoses & Files
      for (final diag in diagnoses) {
        final diagFolder = Directory(
          '${exportDir.path}/${diag.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}',
        );
        await diagFolder.create();

        // Fetch documents for this diagnosis
        final docs = await getDiagnosisDocuments(diag.title);
        for (final docData in docs) {
          final localPath = docData['local_path'] as String?;
          if (localPath != null && localPath.isNotEmpty) {
            final file = File(localPath);
            if (await file.exists()) {
              final fileName = p.basename(localPath);
              await file.copy('${diagFolder.path}/$fileName');
            }
          }
        }

        // Add diagnosis specific JSON summary
        final diagFile = File('${diagFolder.path}/diagnosis_info.json');
        await diagFile.writeAsString(
          jsonEncode(_makeEncodable(diag.toFirestore())),
        );
      }

      // 4. Save Main Summary JSON
      final summaryFile = File('${exportDir.path}/all_health_summary.json');
      await summaryFile.writeAsString(
        jsonEncode(_makeEncodable(exportSummary)),
      );

      return exportDir.path;
    } catch (e) {
      rethrow;
    }
  }

  /// Recursively convert Firestore-specific objects (like Timestamp) to encodable values
  dynamic _makeEncodable(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is FieldValue) {
      return value.toString();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _makeEncodable(v)));
    }
    if (value is List) {
      return value.map(_makeEncodable).toList();
    }
    return value;
  }

  // Fetch all diagnoses for the user with caching
  Future<List<DiagnosisItem>> getDiagnoses({bool forceRefresh = false}) async {
    if (_cachedDiagnoses != null && !forceRefresh) {
      return _cachedDiagnoses!;
    }

    final uid = currentUid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .get();

    final diagnoses = snapshot.docs
        .map((doc) => DiagnosisItem.fromFirestore(doc))
        .toList();

    // Sort in-memory to ensure all records appear even if timestamps are missing in DB
    diagnoses.sort((a, b) => b.diagnosedDate.compareTo(a.diagnosedDate));

    _cachedDiagnoses = diagnoses;
    return _cachedDiagnoses!;
  }

  // Save or Update a full diagnosis record
  Future<void> addDiagnosis(
    DiagnosisItem diagnosis, {
    String? doctorName,
    String? visitDate,
    String? notes,
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    final diagRef = _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosis.title);

    // Save main diagnosis data
    await diagRef.set(diagnosis.toFirestore(), SetOptions(merge: true));

    // Save Doctor Info & Notes in a sub-collection
    if ((doctorName != null && doctorName.isNotEmpty) ||
        (notes != null && notes.isNotEmpty)) {
      await diagRef.collection('doctor_info').doc('primary_doctor').set({
        'name': doctorName ?? '',
        'last_visit': visitDate ?? '',
        'notes': notes ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // Clear diagnoses cache to force refresh
    _cachedDiagnoses = null;
  }

  // Fetch all doctor notes/info for a specific diagnosis
  Future<List<Map<String, dynamic>>> getDoctorNotes(
    String diagnosisName,
  ) async {
    final uid = currentUid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('doctor_info')
        .orderBy('updated_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Update only the description of a diagnosis
  Future<void> updateDiagnosisDescription(
    String diagnosisName,
    String description,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .update({'description': description});

    _cachedDiagnoses = null;
  }

  // Save Secondary Doctor Info
  Future<void> addSecondaryDoctor(
    String diagnosisName,
    Map<String, dynamic> doctorData,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('doctor_info')
        .doc('secondary_doctor')
        .set({
          ...doctorData,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // Save Document Metadata
  Future<void> saveDocumentMetadata(
    String diagnosisName,
    Map<String, dynamic> metadata,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('documents')
        .add({...metadata, 'uploaded_at': FieldValue.serverTimestamp()});
  }

  // Fetch Documents for a Diagnosis
  Future<List<Map<String, dynamic>>> getDiagnosisDocuments(
    String diagnosisName,
  ) async {
    final uid = currentUid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('documents')
        .orderBy('uploaded_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Delete Document Record
  Future<void> deleteDocumentRecord(
    String diagnosisName,
    String documentId,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('documents')
        .doc(documentId)
        .delete();
  }

  // Delete Full Diagnosis
  Future<void> deleteDiagnosis(String diagnosisName) async {
    final uid = currentUid;
    if (uid == null) return;

    final diagRef = _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName);

    // 1. Delete Firestore Sub-collections (doctor_info and documents)
    // Note: We only delete the documents inside, not the collection itself (Firestore standard)
    final doctorInfoSnap = await diagRef.collection('doctor_info').get();
    for (var doc in doctorInfoSnap.docs) {
      await doc.reference.delete();
    }

    final documentsSnap = await diagRef.collection('documents').get();
    for (var doc in documentsSnap.docs) {
      await doc.reference.delete();
    }

    // 2. Delete Main Document
    await diagRef.delete();

    // 3. Delete Local Storage folder
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final storageDir = Directory(
        '${appDir.path}/medvault/diagnoses/$diagnosisName',
      );
      if (await storageDir.exists()) {
        await storageDir.delete(recursive: true);
      }
    } catch (e) {
      // Error deleting local storage
    }

    // Clear cache
    _cachedDiagnoses = null;
  }

  // --- Medication / Prescription Methods ---

  // Add Medication (Conditional routing)
  Future<void> addMedication(Medication medication) async {
    final uid = currentUid;
    if (uid == null) return;

    DocumentReference medRef;
    if (medication.diagnosisId == null || medication.diagnosisId == 'General') {
      // Store in General_medication
      medRef = _db
          .collection('users')
          .doc(uid)
          .collection('General_medication')
          .doc(medication.name);
    } else {
      // Store in specific diagnosis prescriptions sub-collection
      medRef = _db
          .collection('users')
          .doc(uid)
          .collection('diagnoses')
          .doc(medication.diagnosisId!)
          .collection('prescriptions')
          .doc(medication.name);
    }

    await medRef.set(medication.toFirestore(), SetOptions(merge: true));

    // Schedule Reminders
    await NotificationService().scheduleMedicationReminders(medication);
    await AlarmService().scheduleMedicationAlarms(medication);

    // Clear medication cache
    _cachedMedications = null;
  }

  // Fetch all medications across all sources with caching
  Future<List<Medication>> getAllUserMedications({
    bool forceRefresh = false,
  }) async {
    if (_cachedMedications != null && !forceRefresh) {
      return _cachedMedications!;
    }
    final uid = currentUid;
    if (uid == null) return [];

    List<Medication> allMeds = [];

    // 1. Fetch from General_medication
    final generalSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('General_medication')
        .get();
    allMeds.addAll(
      generalSnap.docs.map((doc) => Medication.fromFirestore(doc)),
    );

    // 2. Fetch from all diagnosis prescriptions
    final diagnosesSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .get();

    for (var diagDoc in diagnosesSnap.docs) {
      final prescriptionsSnap = await diagDoc.reference
          .collection('prescriptions')
          .get();
      allMeds.addAll(
        prescriptionsSnap.docs.map((doc) => Medication.fromFirestore(doc)),
      );
    }

    // 3. Deduplicate by name (preferring diagnosis-specific ones if conflict exists)
    final Map<String, Medication> uniqueMeds = {};
    for (var med in allMeds) {
      // If conflict, keep the one with a diagnosisId or the newer one
      if (!uniqueMeds.containsKey(med.name) || med.diagnosisId != null) {
        uniqueMeds[med.name] = med;
      }
    }
    allMeds = uniqueMeds.values.toList();

    // Sort by creation date if available
    allMeds.sort((a, b) {
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    _cachedMedications = allMeds;
    return _cachedMedications!;
  }

  // Fetch medications for a specific diagnosis
  Future<List<Medication>> getDiagnosisPrescriptions(
    String diagnosisName,
  ) async {
    final uid = currentUid;
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .doc(diagnosisName)
        .collection('prescriptions')
        .get();

    return snapshot.docs.map((doc) => Medication.fromFirestore(doc)).toList();
  }

  // Delete Medication
  Future<void> deleteMedication(
    String medicationName, {
    String? diagnosisId,
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    DocumentReference medRef;
    if (diagnosisId == null || diagnosisId == 'General') {
      medRef = _db
          .collection('users')
          .doc(uid)
          .collection('General_medication')
          .doc(medicationName);
    } else {
      medRef = _db
          .collection('users')
          .doc(uid)
          .collection('diagnoses')
          .doc(diagnosisId)
          .collection('prescriptions')
          .doc(medicationName);
    }

    await medRef.delete();

    // Cancel Reminders
    await NotificationService().cancelMedicationReminders(medicationName);
    await AlarmService().cancelMedicationAlarms(medicationName);

    // Clear medication cache
    _cachedMedications = null;
  }

  // Update Medication (Handles moving between General and Diagnosis)
  Future<void> updateMedication(Medication original, Medication updated) async {
    final uid = currentUid;
    if (uid == null) return;

    // If name or diagnosisId changed, we need to delete the old one and create a new one
    bool pathChanged =
        original.name != updated.name ||
        original.diagnosisId != updated.diagnosisId;

    if (pathChanged) {
      await deleteMedication(original.name, diagnosisId: original.diagnosisId);
    }

    // addMedication handles the correct routing and merging
    await addMedication(updated);

    // Clear medication cache
    _cachedMedications = null;
  }

  // Mark medication as completed
  Future<void> completeMedication(Medication med) async {
    // Create an updated version
    final updatedMed = Medication(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      instructions: med.instructions,
      prescribedBy: med.prescribedBy,
      prescribedDate: med.prescribedDate,
      pharmacy: med.pharmacy,
      refillsRemaining: med.refillsRemaining,
      expiryDate: med.expiryDate,
      notes: med.notes,
      diagnosisId: med.diagnosisId,
      enableReminders: false, // Permanently disable reminders
      reminderTimes: med.reminderTimes,
      isCompleted: true, // Mark as completed
      createdAt: med.createdAt,
    );

    // Save and handle cancellations
    await addMedication(updatedMed);
  }

  // --- Appointment Methods ---

  Future<void> addAppointment(Appointment appointment) async {
    final uid = currentUid;
    if (uid == null) return;

    DocumentReference apptRef;
    if (appointment.linkedDiagnosis == 'General') {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('General_appointments')
          .doc(appointment.id);
    } else {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('diagnoses')
          .doc(appointment.linkedDiagnosis)
          .collection('appointments')
          .doc(appointment.id);
    }

    await apptRef.set({
      'doctorName': appointment.doctorName,
      'specialty': appointment.specialty,
      'date': appointment.date.toIso8601String(),
      'startTime':
          '${appointment.startTime.hour}:${appointment.startTime.minute}',
      'endTime': appointment.endTime != null
          ? '${appointment.endTime!.hour}:${appointment.endTime!.minute}'
          : null,
      'location': appointment.location,
      'reason': appointment.reason,
      'notes': appointment.notes,
      'linkedDiagnosis': appointment.linkedDiagnosis,
      'status': appointment.status,
    }, SetOptions(merge: true));

    _cachedAppointments = null;
  }

  Future<List<Appointment>> getAppointments({bool forceRefresh = false}) async {
    if (_cachedAppointments != null && !forceRefresh) {
      return _cachedAppointments!;
    }
    final uid = currentUid;
    if (uid == null) return [];

    List<Appointment> allAppointments = [];

    // 1. Fetch from General_appointments
    final generalSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('General_appointments')
        .get();

    // Helper to parse appointment from doc
    Appointment parseDoc(QueryDocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      final startTimeParts = (data['startTime'] as String).split(':');
      final endTimeParts = (data['endTime'] as String?)?.split(':');

      return Appointment(
        id: doc.id,
        doctorName: data['doctorName'] ?? '',
        specialty: data['specialty'] ?? '',
        date: DateTime.parse(data['date']),
        startTime: TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1]),
        ),
        endTime: endTimeParts != null
            ? TimeOfDay(
                hour: int.parse(endTimeParts[0]),
                minute: int.parse(endTimeParts[1]),
              )
            : null,
        location: data['location'] ?? '',
        reason: data['reason'] ?? '',
        notes: data['notes'] ?? '',
        linkedDiagnosis: data['linkedDiagnosis'] ?? 'General',
        status: data['status'] ?? 'Upcoming',
      );
    }

    allAppointments.addAll(generalSnap.docs.map(parseDoc));

    // 2. Fetch from all diagnosis appointments
    final diagnosesSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('diagnoses')
        .get();

    for (var diagDoc in diagnosesSnap.docs) {
      final appointmentsSnap = await diagDoc.reference
          .collection('appointments')
          .get();
      allAppointments.addAll(appointmentsSnap.docs.map(parseDoc));
    }

    // Sorting by date and time
    allAppointments.sort((a, b) {
      int dateComp = a.date.compareTo(b.date);
      if (dateComp != 0) return dateComp;
      return (a.startTime.hour * 60 + a.startTime.minute).compareTo(
        b.startTime.hour * 60 + b.startTime.minute,
      );
    });

    // --- AUTO-COMPLETE PAST APPOINTMENTS ---
    bool needsRefresh = false;
    final now = DateTime.now();
    for (var appt in allAppointments) {
      if (appt.status == 'Upcoming') {
        final apptTime = DateTime(
          appt.date.year,
          appt.date.month,
          appt.date.day,
          appt.startTime.hour,
          appt.startTime.minute,
        );

        if (apptTime.isBefore(now)) {
          // It passed!
          await _autoCompleteAppointment(appt);
          needsRefresh = true;
        }
      }
    }

    if (needsRefresh) {
      // Clear cache and fetch again to return updated list
      _cachedAppointments = null;
      return getAppointments(forceRefresh: true);
    }

    _cachedAppointments = allAppointments;
    return allAppointments;
  }

  Future<void> _autoCompleteAppointment(Appointment appointment) async {
    final uid = currentUid;
    if (uid == null) return;

    DocumentReference apptRef;
    if (appointment.linkedDiagnosis == 'General') {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('General_appointments')
          .doc(appointment.id);
    } else {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('diagnoses')
          .doc(appointment.linkedDiagnosis)
          .collection('appointments')
          .doc(appointment.id);
    }

    await apptRef.update({'status': 'Completed'});
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    final uid = currentUid;
    if (uid == null) return;

    DocumentReference apptRef;
    if (appointment.linkedDiagnosis == 'General') {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('General_appointments')
          .doc(appointment.id);
    } else {
      apptRef = _db
          .collection('users')
          .doc(uid)
          .collection('diagnoses')
          .doc(appointment.linkedDiagnosis)
          .collection('appointments')
          .doc(appointment.id);
    }

    await apptRef.delete();

    _cachedAppointments = null;
  }

  // --- Adherence Methods ---

  Future<void> toggleMedicationTakenToday(
    Medication med,
    String reminderTime,
    bool isTaken,
  ) async {
    final uid = currentUid;
    if (uid == null) return;

    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    final Map<String, List<String>> newTakenDoses = Map.from(med.takenDoses);

    final dosesForDate = List<String>.from(newTakenDoses[dateKey] ?? []);
    if (isTaken) {
      if (!dosesForDate.contains(reminderTime)) {
        dosesForDate.add(reminderTime);
      }
    } else {
      dosesForDate.remove(reminderTime);
    }

    if (dosesForDate.isEmpty) {
      newTakenDoses.remove(dateKey);
    } else {
      newTakenDoses[dateKey] = dosesForDate;
    }

    final updatedMed = Medication(
      id: med.id,
      name: med.name,
      dosage: med.dosage,
      frequency: med.frequency,
      instructions: med.instructions,
      prescribedBy: med.prescribedBy,
      prescribedDate: med.prescribedDate,
      pharmacy: med.pharmacy,
      refillsRemaining: med.refillsRemaining,
      expiryDate: med.expiryDate,
      notes: med.notes,
      diagnosisId: med.diagnosisId,
      enableReminders: med.enableReminders,
      reminderTimes: med.reminderTimes,
      isCompleted: med.isCompleted,
      createdAt: med.createdAt,
      takenDoses: newTakenDoses,
    );

    await updateMedication(med, updatedMed);

    // Refresh notifications to skip today's dose if taken
    NotificationService().scheduleMedicationReminders(updatedMed);
    _cachedMedications = null;
  }
}

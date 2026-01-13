import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/models/medication.dart';
import 'package:app/models/appointment.dart';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'dart:typed_data';

class DiagnosisDetailScreen extends StatefulWidget {
  const DiagnosisDetailScreen({super.key});

  @override
  State<DiagnosisDetailScreen> createState() => _DiagnosisDetailScreenState();
}

class _DiagnosisDetailScreenState extends State<DiagnosisDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _descriptionController = TextEditingController();

  DiagnosisItem? diagnosis;
  bool _isLoadingNotes = true;
  bool _isUpdatingDescription = false;
  bool _isLoadingDocuments = true;
  bool _isLoadingPrescriptions = true;
  bool _isLoadingAppointments = true;

  // Doctor notes list - now dynamic
  List<DoctorNote> doctorNotes = [];

  // Documents list - now dynamic
  List<Document> documents = [];

  // Prescriptions list - now dynamic
  List<Medication> prescriptions = [];

  // Related appointments list - now dynamic
  List<Appointment> relatedAppointments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (diagnosis == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is DiagnosisItem) {
        diagnosis = args;
        _descriptionController.text = diagnosis!.description;
        _loadDoctorNotes();
        _loadDocuments();
        _loadPrescriptions();
        _loadRelatedAppointments();
      }
    }
  }

  Future<void> _loadDoctorNotes() async {
    if (diagnosis == null) return;
    setState(() => _isLoadingNotes = true);

    try {
      final notesData = await DatabaseService().getDoctorNotes(
        diagnosis!.title,
      );
      setState(() {
        doctorNotes = notesData.map((data) {
          // Convert Timestamp to String if needed, or handle different types
          String dateStr = 'Unknown Date';
          if (data['last_visit'] != null) {
            dateStr = data['last_visit'].toString();
          } else if (data['updated_at'] != null) {
            final ts = data['updated_at'] as Timestamp;
            final dt = ts.toDate();
            dateStr = '${dt.month}/${dt.day}/${dt.year}';
          }

          return DoctorNote(
            doctorName: data['name'] ?? 'Unknown Doctor',
            date: dateStr,
            comment: data['notes'] ?? '',
          );
        }).toList();
        _isLoadingNotes = false;
      });
    } catch (e) {
      debugPrint('Error loading doctor notes: $e');
      setState(() => _isLoadingNotes = false);
    }
  }

  Future<void> _loadDocuments() async {
    if (diagnosis == null) return;
    setState(() => _isLoadingDocuments = true);

    try {
      final docData = await DatabaseService().getDiagnosisDocuments(
        diagnosis!.title,
      );
      setState(() {
        documents = docData.map((data) {
          String dateStr = 'Unknown Date';
          if (data['uploaded_at'] != null) {
            final ts = data['uploaded_at'] as Timestamp;
            final dt = ts.toDate();
            dateStr = '${dt.month}/${dt.day}/${dt.year}';
          }

          DocumentType type = DocumentType.other;
          if (data['type'] == 'image') type = DocumentType.image;
          if (data['type'] == 'document') type = DocumentType.document;

          return Document(
            id: data['id'],
            title: data['name'] ?? 'Unknown File',
            date: dateStr,
            localPath: data['local_path'] ?? '',
            type: type,
          );
        }).toList();
        _isLoadingDocuments = false;
      });
    } catch (e) {
      debugPrint('Error loading documents: $e');
      setState(() => _isLoadingDocuments = false);
    }
  }

  Future<void> _loadPrescriptions() async {
    if (diagnosis == null) return;
    setState(() => _isLoadingPrescriptions = true);

    try {
      final meds = await DatabaseService().getDiagnosisPrescriptions(
        diagnosis!.title,
      );
      setState(() {
        prescriptions = meds;
        _isLoadingPrescriptions = false;
      });
    } catch (e) {
      debugPrint('Error loading prescriptions: $e');
      setState(() => _isLoadingPrescriptions = false);
    }
  }

  Future<void> _loadRelatedAppointments() async {
    if (diagnosis == null) return;
    setState(() => _isLoadingAppointments = true);

    try {
      final allAppts = await DatabaseService().getAppointments();
      setState(() {
        // Filter by diagnosis title
        relatedAppointments = allAppts
            .where((a) => a.linkedDiagnosis == diagnosis!.title)
            .toList();

        // Sort by date (descending to see most recent/future first)
        relatedAppointments.sort((a, b) => b.date.compareTo(a.date));

        _isLoadingAppointments = false;
      });
    } catch (e) {
      debugPrint('Error loading related appointments: $e');
      setState(() => _isLoadingAppointments = false);
    }
  }

  Future<void> _deletePrescription(Medication medication) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.themedWith(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Prescription',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B2F33).themedWith(isDark),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${medication.name} for this diagnosis?',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278).themedWith(isDark),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF6C7278,
                      ).themedWith(isDark),
                      side: BorderSide(
                        color: const Color(0xFFE0E0E0).themedWith(isDark),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.themedWith(isDark),
                      foregroundColor: Colors.white.themedWith(isDark),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService().deleteMedication(
          medication.name,
          diagnosisId: diagnosis!.title,
        );
        _loadPrescriptions();
      } catch (e) {
        debugPrint('Error deleting prescription: $e');
      }
    }
  }

  Future<void> _pickAndUploadDocument() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (diagnosis == null) return;

    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.single.path == null) return;

      final pickedFile = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileExtension = fileName.split('.').last.toLowerCase();

      // Determine type
      String typeStr = 'other';
      if (['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension)) {
        typeStr = 'image';
      }
      if (['pdf', 'doc', 'docx', 'txt'].contains(fileExtension)) {
        typeStr = 'document';
      }

      // 1. Get Application Directory
      final appDir = await getApplicationDocumentsDirectory();
      final storageDir = Directory(
        '${appDir.path}/medvault/diagnoses/${diagnosis!.title}/documents',
      );

      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }

      // 2. Copy Physical File
      final localPath = '${storageDir.path}/$fileName';
      await pickedFile.copy(localPath);

      // 3. Save Metadata to Firestore
      await DatabaseService().saveDocumentMetadata(diagnosis!.title, {
        'name': fileName,
        'local_path': localPath,
        'type': typeStr,
        'file_size':
            '${(pickedFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
      });

      // 4. Refresh List
      _loadDocuments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName uploaded locally.'),
          backgroundColor: const Color(0xFF3AC0A0).themedWith(isDark),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied or error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewDocument(String localPath) async {
    if (localPath.isEmpty) return;

    final file = File(localPath);
    if (await file.exists()) {
      await OpenFilex.open(localPath);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File not found on this device.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteDocument(String id, String localPath) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (diagnosis == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.themedWith(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Document',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B2F33).themedWith(isDark),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this document from your device?',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278).themedWith(isDark),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF6C7278,
                      ).themedWith(isDark),
                      side: BorderSide(
                        color: const Color(0xFFE0E0E0).themedWith(isDark),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.themedWith(isDark),
                      foregroundColor: Colors.white.themedWith(isDark),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1. Delete physical file
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }

      // 2. Delete Firestore record
      await DatabaseService().deleteDocumentRecord(diagnosis!.title, id);

      // 3. Refresh list
      _loadDocuments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDescription() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (diagnosis == null) return;
    setState(() => _isUpdatingDescription = true);

    try {
      await DatabaseService().updateDiagnosisDescription(
        diagnosis!.title,
        _descriptionController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Description updated successfully!'),
          backgroundColor: const Color(0xFF4CAF50).themedWith(isDark),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdatingDescription = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddDoctorNoteDialog(bool isDark) {
    final TextEditingController doctorNameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.themedWith(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Doctor Note',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(
                        255,
                        67,
                        71,
                        75,
                      ).themedWith(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: doctorNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Dr. Michael Chen',
                      hintStyle: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: const Color(0xFF277AFF).themedWith(isDark),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF277AFF),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Date of Visit / Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(
                        255,
                        67,
                        71,
                        75,
                      ).themedWith(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'mm/dd/yyyy',
                      hintStyle: TextStyle(
                        color: const Color(0xFFB0B0B0).themedWith(isDark),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: const Color(0xFF3AC0A0).themedWith(isDark),
                        size: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9).themedWith(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: const Color(0xFF3AC0A0),
                                primary: const Color(
                                  0xFF3AC0A0,
                                ).themedWith(isDark),
                                onPrimary: Colors.white.themedWith(isDark),
                                surface: Colors.white.themedWith(isDark),
                                onSurface: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        dateController.text =
                            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Notes / Comments',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(
                        255,
                        67,
                        71,
                        75,
                      ).themedWith(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Doctor notes or comments...',
                      hintStyle: TextStyle(
                        color: const Color(0xFFB0B0B0).themedWith(isDark),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9).themedWith(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF6C7278).themedWith(isDark),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (doctorNameController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    commentController.text.isNotEmpty) {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF277AFF).themedWith(isDark),
                      ),
                    ),
                  );

                  try {
                    await DatabaseService()
                        .addSecondaryDoctor(diagnosis!.title, {
                          'name': doctorNameController.text.trim(),
                          'last_visit': dateController.text.trim(),
                          'notes': commentController.text.trim(),
                        });

                    if (context.mounted) Navigator.pop(context); // Pop loading
                    if (context.mounted) Navigator.pop(context); // Pop dialog

                    _loadDoctorNotes(); // Refresh list
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context); // Pop loading
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF277AFF).themedWith(isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Column(
              children: [
                // Top Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white.themedWith(isDark),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'Diagnosis Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.themedWith(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 20),

                // Diagnosis Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          "assets/images/icon for Medvault/filetext.svg",
                          colorFilter: ColorFilter.mode(
                            const Color(0xFF277AFF).themedWith(isDark),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Diagnosis Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diagnosis?.title ?? 'Loading...',
                              style: TextStyle(
                                color: Colors.white.themedWith(isDark),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    diagnosis?.statusText ?? '...',
                                    style: TextStyle(
                                      color: Colors.white.themedWith(isDark),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.white.themedWith(isDark),
                                        size: 8,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        diagnosis?.severityText ?? '...',
                                        style: TextStyle(
                                          color: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.white.themedWith(isDark),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'First diagnosed: ${diagnosis?.formattedDate ?? '...'}',
                                  style: TextStyle(
                                    color: Colors.white.themedWith(isDark),
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white.themedWith(isDark),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF277AFF).themedWith(isDark),
              unselectedLabelColor: const Color(0xFF9E9E9E).themedWith(isDark),
              indicatorColor: const Color(0xFF277AFF).themedWith(isDark),
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Documents'),
                Tab(text: 'Prescriptions'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isDark),
                _buildDocumentsTab(isDark),
                _buildPrescriptionsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color.fromARGB(
                  178,
                  212,
                  212,
                  212,
                ).themedWith(isDark),
                width: 1,
              ),
            ),
            color: Colors.white.themedWith(isDark),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                      if (_isUpdatingDescription)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: _updateDescription,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Update'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF277AFF),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF2B2F33).themedWith(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a description for this diagnosis...',
                      hintStyle: TextStyle(
                        color: const Color(0xFFB0B0B0).themedWith(isDark),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white.themedWith(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF277AFF).themedWith(isDark),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Doctor Notes & Comments Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color.fromARGB(
                  178,
                  212,
                  212,
                  212,
                ).themedWith(isDark),
                width: 1,
              ),
            ),
            color: Colors.white.themedWith(isDark),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Doctor Notes & Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddDoctorNoteDialog(isDark),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF277AFF,
                          ).themedWith(isDark),
                          foregroundColor: Colors.white.themedWith(isDark),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingNotes)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: LoadingAnimation(size: 80),
                      ),
                    )
                  else if (doctorNotes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No doctor notes yet.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey.themedWith(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ...doctorNotes.map(
                      (note) => _buildDoctorNoteItem(note, isDark),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Related Appointments Section
          Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color.fromARGB(
                  178,
                  212,
                  212,
                  212,
                ).themedWith(isDark),
                width: 1,
              ),
            ),
            color: const Color(0xFF3AC0A0).themedWith(isDark),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Related Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white.themedWith(isDark),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/addAppointment',
                            arguments: diagnosis?.title,
                          );
                          if (result == true) {
                            _loadRelatedAppointments();
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withValues(alpha: 0.25)
                              .themedWith(isDark),
                          foregroundColor: Colors.white.themedWith(isDark),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingAppointments)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: LoadingAnimation(size: 80),
                      ),
                    )
                  else if (relatedAppointments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No appointments yet',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.themedWith(isDark),
                          ),
                        ),
                      ),
                    )
                  else
                    ...relatedAppointments.map(
                      (appointment) =>
                          _buildAppointmentItem(appointment, isDark),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorNoteItem(DoctorNote note, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF277AFF,
                  ).themedWith(isDark).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: const Color(0xFF277AFF).themedWith(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.doctorName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                    Text(
                      note.date,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF9E9E9E).themedWith(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              note.comment,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                color: const Color(0xFF2B2F33).themedWith(isDark),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment, bool isDark) {
    final bool isCompleted = appointment.status == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(35, 255, 255, 255).themedWith(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.white.themedWith(isDark),
                      ),
                    ),
                    Text(
                      appointment.specialty,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Colors.white.themedWith(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Colors.white.themedWith(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/appointmentEdit',
                        arguments: appointment,
                      );
                      if (result == true) {
                        _loadRelatedAppointments();
                      }
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white.themedWith(isDark),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.white.themedWith(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                appointment.formattedDate,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: Colors.white.themedWith(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.white.themedWith(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                appointment.formatTime(context),
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: Colors.white.themedWith(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.white.themedWith(isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.location,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: Colors.white.themedWith(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upload Document Button
          ElevatedButton(
            onPressed: _pickAndUploadDocument,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF277AFF).themedWith(isDark),
              foregroundColor: Colors.white.themedWith(isDark),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file_outlined),
                const SizedBox(width: 8),
                Text(
                  'Upload Document',
                  style: TextStyle(color: Colors.white.themedWith(isDark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Documents Grid
          if (_isLoadingDocuments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: LoadingAnimation(size: 80),
              ),
            )
          else if (documents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_copy_outlined,
                      size: 48,
                      color: Colors.grey.themedWith(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No documents uploaded for this diagnosis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.themedWith(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                return _buildDocumentCard(documents[index], isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview / Icon
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD).themedWith(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildFilePreview(document, isDark),
              ),
            ),
            const SizedBox(height: 5),
            // Title and Date
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  document.date,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF9E9E9E).themedWith(isDark),
                  ),
                ),
              ],
            ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // View Button
                TextButton(
                  onPressed: () => _viewDocument(document.localPath),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF277AFF).themedWith(isDark),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    alignment: Alignment.centerLeft,
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/images/icon for Medvault/Eye.svg",
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF3AC0A0).themedWith(isDark),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View',
                        style: TextStyle(
                          color: const Color(0xFF3AC0A0).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Delete Button
                IconButton(
                  onPressed: () =>
                      _deleteDocument(document.id, document.localPath),
                  icon: SvgPicture.asset(
                    "assets/images/icon for Medvault/Trash2.svg",
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.red.themedWith(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add Prescription Button
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/addmedicine');
              if (result == true) {
                _loadPrescriptions();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF277AFF).themedWith(isDark),
              foregroundColor: Colors.white.themedWith(isDark),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/icon for Medvault/plus.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Colors.white.themedWith(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Add Prescription'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Prescriptions List
          _isLoadingPrescriptions
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: LoadingAnimation(size: 60),
                  ),
                )
              : prescriptions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'No prescriptions linked to this diagnosis.',
                      style: TextStyle(color: Colors.grey.themedWith(isDark)),
                    ),
                  ),
                )
              : Column(
                  children: prescriptions
                      .map((m) => _buildPrescriptionCard(m, isDark))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Medication medication, bool isDark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF).themedWith(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/images/icon for Medvault/pill.svg",
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF277AFF).themedWith(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Medication Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosage} - ${medication.frequency}',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 8),

                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prescribed By
            Row(
              children: [
                Text(
                  'Prescribed by:',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF6C7278).themedWith(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  medication.prescribedBy,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF6C7278).themedWith(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  medication.prescribedDate,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Instructions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF6C7278).themedWith(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication.instructions,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF2B2F33).themedWith(isDark),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Go to Detail Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/medDetail',
                      ); // Generic detail for now
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF3AC0A0,
                      ).themedWith(isDark),
                      foregroundColor: Colors.white.themedWith(isDark),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Go to Detail'),
                  ),
                ),
                const SizedBox(width: 12),
                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deletePrescription(medication),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.themedWith(isDark),
                      foregroundColor: Colors.white.themedWith(isDark),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Document document, bool isDark) {
    if (document.type == DocumentType.image && document.localPath.isNotEmpty) {
      final file = File(document.localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultFileIcon(document.type, isDark),
        );
      }
    } else if (document.type == DocumentType.document &&
        document.localPath.toLowerCase().endsWith('.pdf')) {
      return FutureBuilder<Uint8List?>(
        future: _renderPdfThumbnail(document.localPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return _buildDefaultFileIcon(document.type, isDark);
        },
      );
    }

    return _buildDefaultFileIcon(document.type, isDark);
  }

  Future<Uint8List?> _renderPdfThumbnail(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;

      final document = await PdfDocument.openFile(path);
      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.jpeg,
        quality: 50,
      );
      await page.close();
      await document.close();
      return pageImage?.bytes;
    } catch (e) {
      debugPrint('Error rendering PDF thumbnail: $e');
      return null;
    }
  }

  Widget _buildDefaultFileIcon(DocumentType type, bool isDark) {
    String iconPath = "assets/images/icon for Medvault/filetext.svg";
    // You could add different icons for PDF vs Doc here if you have them

    return Center(
      child: SvgPicture.asset(
        iconPath,
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(
          const Color(0xFF277AFF).themedWith(isDark),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

// Data Models
class DoctorNote {
  final String doctorName;
  final String date;
  final String comment;

  DoctorNote({
    required this.doctorName,
    required this.date,
    required this.comment,
  });
}

enum DocumentType { document, image, other }

class Document {
  final String id;
  final String title;
  final String date;
  final String localPath;
  final DocumentType type;

  Document({
    required this.id,
    required this.title,
    required this.date,
    required this.localPath,
    required this.type,
  });
}

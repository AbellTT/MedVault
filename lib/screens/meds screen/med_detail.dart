import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/models/medication.dart';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';

class MedDetail extends StatefulWidget {
  const MedDetail({super.key});

  @override
  State<MedDetail> createState() => _MedDetailState();
}

class _MedDetailState extends State<MedDetail> {
  bool _isInitialized = false;
  late Medication medication;
  bool _remindersEnabled = false;

  final TextEditingController _timeController = TextEditingController();
  List<String> _reminderTimes = []; // Store as "HH:mm"

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Medication) {
        medication = args;
        _remindersEnabled = medication.enableReminders;
        _reminderTimes = List<String>.from(medication.reminderTimes);
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        children: [
          // Header with medication info
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Column(
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(
                      'Medication Details',
                      style: TextStyle(
                        color: Colors.white.themedWith(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/medDetailEdit',
                          arguments: medication,
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(
                            context,
                          ); // Return to dashboard to refresh
                        }
                      },
                      icon: SvgPicture.asset(
                        "assets/images/icon for Medvault/edit2.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Colors.white.themedWith(isDark),
                          BlendMode.srcIn,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Medication name and dosage
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .themedWith(isDark)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: SvgPicture.asset(
                          "assets/images/icon for Medvault/pill.svg",
                          colorFilter: ColorFilter.mode(
                            Colors.white.themedWith(isDark),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: TextStyle(
                            color: Colors.white.themedWith(isDark),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosage,
                          style: TextStyle(
                            color: Colors.white.themedWith(isDark),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLinkedDiagnosisCard(isDark),
                  const SizedBox(height: 16),

                  // Dosage & Instructions
                  _buildDosageInstructionsCard(isDark),
                  const SizedBox(height: 16),

                  // Schedule & Reminders
                  _buildScheduleRemindersCard(isDark),
                  const SizedBox(height: 16),

                  // Prescription Information
                  _buildPrescriptionInfoCard(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedDiagnosisCard(bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
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
              children: [
                SvgPicture.asset(
                  "assets/images/icon for Medvault/filetext.svg",
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF277AFF).themedWith(isDark),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Linked Diagnosis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD).themedWith(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                medication.diagnosisId ?? 'General',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF277AFF).themedWith(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageInstructionsCard(bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosage & Instructions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: const Color(0xFF2B2F33).themedWith(isDark),
              ),
            ),
            const SizedBox(height: 16),

            // Dosage
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD).themedWith(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosage',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frequency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F1).themedWith(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: const Color(0xFF3AC0A0).themedWith(isDark),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequency',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.frequency,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Instructions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F1).themedWith(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF3AC0A0).themedWith(isDark),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.instructions.isNotEmpty
                            ? medication.instructions
                            : 'No instructions provided',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Important Notes
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6).themedWith(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: const Color(0xFFFBC02D).themedWith(isDark),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medication.notes.isNotEmpty
                            ? medication.notes
                            : 'No additional notes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRemindersCard(bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
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
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/icon for Medvault/calendar.svg",
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF277AFF),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule & Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _remindersEnabled = !_remindersEnabled;
                    });
                    await _saveRemindersToDatabase();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: _remindersEnabled
                        ? const Color(0xFFFFEBEE).themedWith(isDark)
                        : const Color(0xFFE8F5F1).themedWith(isDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _remindersEnabled
                            ? Icons.notifications_off
                            : Icons.notifications_active,
                        size: 16,
                        color: _remindersEnabled
                            ? Colors.red
                            : const Color(0xFF3AC0A0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _remindersEnabled ? 'Disable' : 'Enable',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: _remindersEnabled
                              ? Colors.red
                              : const Color(0xFF3AC0A0).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Frequency
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: Color(0xFF6C7278),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF6C7278).themedWith(isDark),
                      ),
                    ),
                    Text(
                      medication.frequency,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (_remindersEnabled) ...[
              const SizedBox(height: 16),
              Text(
                'Reminder Times',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF6C7278).themedWith(isDark),
                ),
              ),
              const SizedBox(height: 12),

              // Reminder times list
              ..._reminderTimes.map(
                (reminder) => _buildReminderItem(reminder, isDark),
              ),

              const SizedBox(height: 12),
              // Add reminder button
              TextButton.icon(
                onPressed: () => _showAddReminderBottomSheet(isDark),
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: Color(0xFF277AFF),
                ),
                label: const Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFF277AFF),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No reminders set',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: (Colors.grey[600] ?? Colors.grey).themed(
                          context,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _showAddReminderBottomSheet(isDark);
                      },
                      child: const Text(
                        'Add your first reminder',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF277AFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfoCard(bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prescription Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: const Color(0xFF2B2F33).themedWith(isDark),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Prescribed Date',
              medication.prescribedDate.isNotEmpty
                  ? medication.prescribedDate
                  : 'Not specified',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Prescribed By',
              medication.prescribedBy.isNotEmpty
                  ? medication.prescribedBy
                  : 'Not specified',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Pharmacy',
              medication.pharmacy.isNotEmpty
                  ? medication.pharmacy
                  : 'Not specified',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Refills Remaining',
              medication.refillsRemaining.toString(),
              isDark,
              valueColor: const Color(0xFF3AC0A0),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Expiry Date',
              medication.expiryDate.isNotEmpty
                  ? medication.expiryDate
                  : 'Not specified',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: const Color(0xFF6C7278).themedWith(isDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color:
                valueColor?.themedWith(isDark) ??
                const Color(0xFF2B2F33).themedWith(isDark),
          ),
        ),
      ],
    );
  }

  void _showAddReminderBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white.themedWith(isDark),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Reminder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF2B2F33).themedWith(isDark),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF6C7278).themedWith(isDark),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? const ColorScheme.dark(
                                  primary: Color(0xFF3AC0A0),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1E1E1E),
                                  onSurface: Colors.white,
                                )
                              : const ColorScheme.light(
                                  primary: Color(0xFF3AC0A0),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF2B2F33),
                                ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    final String formattedTime =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    _timeController.text =
                        formattedTime; // Keep internal as 24h for saving logic
                  }
                },
                decoration: _inputDecoration('--:-- --', isDark), 
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_timeController.text.isNotEmpty) {
                          setState(() {
                            // Store in HH:mm 24h format for NotificationService
                            // We need to parse the displayed format back to 24h
                            _reminderTimes.add(_timeController.text);
                            _remindersEnabled = true;
                          });
                          _timeController.clear();
                          Navigator.pop(context);
                          await _saveRemindersToDatabase();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AC0A0),
                        foregroundColor: Colors.white.themedWith(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Save Reminder'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _timeController.clear();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(
                          0xFF6C7278,
                        ).themedWith(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: const Color(0xFFE0E0E0).themedWith(isDark),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFB0B0B0).themedWith(isDark),
        fontSize: 14,
        fontFamily: 'Poppins',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _saveRemindersToDatabase() async {
    final updatedMed = Medication(
      id: medication.id,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      instructions: medication.instructions,
      prescribedBy: medication.prescribedBy,
      prescribedDate: medication.prescribedDate,
      pharmacy: medication.pharmacy,
      refillsRemaining: medication.refillsRemaining,
      expiryDate: medication.expiryDate,
      notes: medication.notes,
      diagnosisId: medication.diagnosisId,
      enableReminders: _remindersEnabled,
      reminderTimes: _reminderTimes,
      createdAt: medication.createdAt,
    );

    try {
      await DatabaseService().updateMedication(medication, updatedMed);
      if (mounted) {
        setState(() {
          medication = updatedMed;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving reminders: $e')));
      }
    }
  }

  Widget _buildReminderItem(String time, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.themedWith(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0).themedWith(isDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm, size: 18, color: Color(0xFF3AC0A0)),
              const SizedBox(width: 12),
              Text(
                _formatTo12h(time),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: const Color(0xFF2B2F33).themedWith(isDark),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                _reminderTimes.remove(time);
              });
              await _saveRemindersToDatabase();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatTo12h(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }
}

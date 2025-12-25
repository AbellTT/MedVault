import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MedDetail extends StatefulWidget {
  const MedDetail({super.key});

  @override
  State<MedDetail> createState() => _MedDetailState();
}

class _MedDetailState extends State<MedDetail> {
  bool _remindersEnabled = true;
  final TextEditingController _timeController = TextEditingController();
  String _selectedFrequency = 'Once Daily';

  final List<String> _frequencyOptions = [
    'Once Daily',
    'Twice Daily',
    'Three Times Daily',
    'Four Times Daily',
    'Every Other Day',
    'Weekly',
    'As Needed (PRN)',
  ];

  final List<ReminderTime> _reminderTimes = [
    ReminderTime(time: '8:00 AM'),
    ReminderTime(time: '8:00 PM'),
  ];
  String medicationName = 'Metformin';
  String dosage = '500mg';
  String instructions =
      'Take with food to minimize stomach upset. Do not crush or chew tablets.';
  String prescribedBy = 'Dr. Sarah Johnson';
  String prescribedDate = '01/10/2023';
  String pharmacy = 'CVS Pharmacy';
  String refills = '3';
  String expiryDate = '12/31/2025';
  String additionalNotes =
      'Monitor blood sugar levels regularly. Report any unusual symptoms.';
  String diagnosis = 'Type 2 Diabetes';
  String frequency = 'Twice Daily';

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header with medication info
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(color: Color(0xFF277AFF)),
            child: Column(
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Text(
                      'Medication Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/medDetailEdit');
                      },
                      icon: SvgPicture.asset(
                        "assets/images/icon for Medvault/edit2.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: SvgPicture.asset(
                          "assets/images/icon for Medvault/pill.svg",
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
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
                          medicationName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dosage,
                          style: const TextStyle(
                            color: Colors.white,
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
                  // Linked Diagnosis
                  _buildLinkedDiagnosisCard(),
                  const SizedBox(height: 16),

                  // Dosage & Instructions
                  _buildDosageInstructionsCard(),
                  const SizedBox(height: 16),

                  // Schedule & Reminders
                  _buildScheduleRemindersCard(),
                  const SizedBox(height: 16),

                  // Prescription Information
                  _buildPrescriptionInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedDiagnosisCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      color: Colors.white,
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
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF277AFF),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Linked Diagnosis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFF2B2F33),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                diagnosis,
                style: const TextStyle(
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
    );
  }

  Widget _buildDosageInstructionsCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dosage & Instructions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Color(0xFF2B2F33),
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
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      "assets/images/icon for Medvault/pill.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF277AFF),
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
                      const Text(
                        'Dosage',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dosage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2B2F33),
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
                    color: const Color(0xFFE8F5F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFF3AC0A0),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequency',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        frequency,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2B2F33),
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
                    color: const Color(0xFFE8F5F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF3AC0A0),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        instructions,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2B2F33),
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
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFFBC02D),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Important Notes',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        additionalNotes,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2B2F33),
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

  Widget _buildScheduleRemindersCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      color: Colors.white,
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
                    const Text(
                      'Schedule & Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2B2F33),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _remindersEnabled = !_remindersEnabled;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: _remindersEnabled
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5F1),
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
                              : const Color(0xFF3AC0A0),
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
                    const Text(
                      'Frequency',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Color(0xFF6C7278),
                      ),
                    ),
                    Text(
                      frequency,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2B2F33),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (_remindersEnabled) ...[
              const SizedBox(height: 16),
              const Text(
                'Reminder Times',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: Color(0xFF6C7278),
                ),
              ),
              const SizedBox(height: 12),

              // Reminder times list
              ..._reminderTimes.map(
                (reminder) => _buildReminderTimeItem(reminder),
              ),

              const SizedBox(height: 12),
              // Add reminder button
              TextButton.icon(
                onPressed: () {
                  _showAddReminderBottomSheet();
                },
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
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _showAddReminderBottomSheet();
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

  Widget _buildReminderTimeItem(ReminderTime reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active,
            size: 20,
            color: Color(0xFF3AC0A0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Color(0xFF2B2F33),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit reminder - Coming soon'),
                  backgroundColor: Color(0xFF277AFF),
                ),
              );
            },
            icon: SvgPicture.asset(
              "assets/images/icon for Medvault/edit2.svg",
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF277AFF),
                BlendMode.srcIn,
              ),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              setState(() {
                _reminderTimes.remove(reminder);
              });
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionInfoCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prescription Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Color(0xFF2B2F33),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Prescribed Date', prescribedDate),
            const SizedBox(height: 12),
            _buildInfoRow('Prescribed By', prescribedBy),
            const SizedBox(height: 12),
            _buildInfoRow('Pharmacy', pharmacy),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Refills Remaining',
              refills,
              valueColor: const Color(0xFF3AC0A0),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Expiry Date', expiryDate),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Color(0xFF6C7278),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: valueColor ?? const Color(0xFF2B2F33),
          ),
        ),
      ],
    );
  }

  void _showAddReminderBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
              const Text(
                'Add Reminder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Color(0xFF2B2F33),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF43474B),
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
                          colorScheme: const ColorScheme.light(
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
                    _timeController.text = picked.format(context);
                  }
                },
                decoration: _inputDecoration('--:-- --'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Color(0xFF43474B),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedFrequency,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                decoration: _dropdownDecoration(),
                items: _frequencyOptions.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2B2F33),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_timeController.text.isNotEmpty) {
                          setState(() {
                            _reminderTimes.add(
                              ReminderTime(time: _timeController.text),
                            );
                            _remindersEnabled = true;
                          });
                          _timeController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3AC0A0),
                        foregroundColor: Colors.white,
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
                        foregroundColor: const Color(0xFF6C7278),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 14,
        fontFamily: 'Poppins',
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
        borderSide: const BorderSide(color: Color(0xFF277AFF), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
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
        borderSide: const BorderSide(color: Color(0xFF277AFF), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class ReminderTime {
  final String time;

  ReminderTime({required this.time});
}

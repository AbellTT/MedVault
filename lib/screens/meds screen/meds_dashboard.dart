import 'package:app/screens/dashboard%20flow/dashboard_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MedsDashboard extends StatefulWidget {
  const MedsDashboard({super.key});

  @override
  State<MedsDashboard> createState() => _MedsDashboardState();
}

class _MedsDashboardState extends State<MedsDashboard> {
  final TextEditingController _searchController = TextEditingController();

  // Sample medication data
  List<Medication> medications = [
    Medication(
      name: "Metformin",
      dosage: "500mg",
      frequency: "2x/day",
      diagnosis: "Type 2 Diabetes",
      diagnosisColor: const Color(0xFF6B9FFF),
      schedule: "Twice Daily",
      nextReminder: "2:00 PM Today",
      nextReminderColor: const Color(0xFF3AC0A0),
    ),
    Medication(
      name: "Lisinopril",
      dosage: "10mg",
      frequency: "1x/day",
      diagnosis: "Hypertension",
      diagnosisColor: const Color(0xFFFF9066),
      schedule: "Once Daily",
      nextReminder: "8:00 AM Tomorrow",
      nextReminderColor: const Color(0xFF3AC0A0),
    ),
    Medication(
      name: "Albuterol Inhaler",
      dosage: "90mcg",
      frequency: "PRN",
      diagnosis: "Asthma",
      diagnosisColor: const Color(0xFFB794F6),
      schedule: "As Needed",
      nextReminder: null,
      nextReminderColor: null,
    ),
    Medication(
      name: "Vitamin D3",
      dosage: "1000 IU",
      frequency: "1x/day",
      diagnosis: "General",
      diagnosisColor: const Color(0xFF48BB78),
      schedule: "Once Daily",
      nextReminder: "9:00 AM Daily",
      nextReminderColor: const Color(0xFF3AC0A0),
    ),
    Medication(
      name: "Cetirizine",
      dosage: "10mg",
      frequency: "1x/day",
      diagnosis: "Seasonal Allergies",
      diagnosisColor: const Color(0xFFECC94B),
      schedule: "Once Daily",
      nextReminder: "10:00 PM Today",
      nextReminderColor: const Color(0xFF3AC0A0),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(color: Color(0xFF277AFF)),
            child: Column(
              children: [
                // Top Bar
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    const Text(
                      'Medications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/medReminders');
                            },
                            icon: SvgPicture.asset(
                              "assets/images/icon for Medvault/clock.svg",
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/addmedicine');
                            },
                            icon: SvgPicture.asset(
                              "assets/images/icon for Medvault/plus.svg",
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medications...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/images/icon for Medvault/search.svg",
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFB0B0B0),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
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
                  // Summary Section - Wrapped in Card like diagnosis
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color.fromARGB(178, 212, 212, 212),
                        width: 1,
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: Color(0xFF2B2F33),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  '5',
                                  'Total',
                                  const Color.fromARGB(118, 232, 241, 255),
                                  const Color(0xFF277AFF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  '4',
                                  'Active',
                                  const Color.fromARGB(118, 232, 245, 233),
                                  const Color(0xFF3AC0A0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  '4',
                                  'Reminders',
                                  const Color.fromARGB(118, 243, 232, 255),
                                  const Color(0xFFB794F6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Medications List
                  ...medications.map(
                    (medication) => _buildMedicationCard(medication),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildSummaryCard(
    String number,
    String label,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
              color: borderColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              color: Color(0xFF6C7278),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color.fromARGB(178, 212, 212, 212),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/medDetail');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('View ${medication.name} details'),
          //     backgroundColor: const Color(0xFF277AFF),
          //   ),
          // );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pill Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/icon for Medvault/pill.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF277AFF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Medication Info + Bell
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Texts
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    medication.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF2B2F33),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${medication.dosage} • ${medication.frequency}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: Color(0xFF6C7278),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                "assets/images/icon for Medvault/bell.svg",
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF3AC0A0),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Chevron
                  SvgPicture.asset(
                    "assets/images/icon for Medvault/chevronright.svg",
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Diagnosis Tag (Gray)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      medication.diagnosis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Color(0xFF6C7278),
                      ),
                    ),
                  ),
                  // Schedule Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          "assets/images/icon for Medvault/calendar.svg",
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6C7278),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medication.schedule,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Color(0xFF6C7278),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                width: double.infinity,
                color: const Color(0xFFE0E0E0),
              ),
              // Next Reminder
              if (medication.nextReminder != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/icon for Medvault/clock.svg",
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        medication.nextReminderColor!,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next reminder: ${medication.nextReminder}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: medication.nextReminderColor,
                      ),
                    ),
                  ],
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Delete ${medication.name}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/images/icon for Medvault/Trash2.svg",
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Colors.red,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
}

// Data Model
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String diagnosis;
  final Color diagnosisColor;
  final String schedule;
  final String? nextReminder;
  final Color? nextReminderColor;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.diagnosis,
    required this.diagnosisColor,
    required this.schedule,
    this.nextReminder,
    this.nextReminderColor,
  });
}

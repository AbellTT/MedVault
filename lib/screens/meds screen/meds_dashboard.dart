import 'package:app/screens/dashboard%20flow/dashboard_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/models/medication.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:app/utils/color_extensions.dart';

class MedsDashboard extends StatefulWidget {
  const MedsDashboard({super.key});

  @override
  State<MedsDashboard> createState() => _MedsDashboardState();
}

class _MedsDashboardState extends State<MedsDashboard> {
  final TextEditingController _searchController = TextEditingController();

  List<Medication> medications = [];
  List<Medication> _filteredMeds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate from cache if available to avoid flicker
    final cache = DatabaseService.cachedMedications;
    if (cache != null) {
      medications = cache;
      _filteredMeds = cache;
      isLoading = false;
    }
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    if (medications.isEmpty) {
      setState(() => isLoading = true);
    }
    try {
      final meds = await DatabaseService().getAllUserMedications();
      setState(() {
        medications = meds;
        _filteredMeds = meds;
        isLoading = false;
      });
      // Re-apply filter if search is not empty
      if (_searchController.text.isNotEmpty) {
        _filterMeds(_searchController.text);
      }
    } catch (e) {
      debugPrint('Error loading medications: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterMeds(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() => _filteredMeds = medications);
      return;
    }

    setState(() {
      _filteredMeds = medications.where((m) {
        return m.name.toLowerCase().contains(trimmedQuery) ||
            m.dosage.toLowerCase().contains(trimmedQuery) ||
            m.instructions.toLowerCase().contains(trimmedQuery);
      }).toList();
    });
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Colors.white.themedWith(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Medication',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B2F33).themedWith(isDark),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${medication.name}?\nThis will cancel all associated reminders.',
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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
        );
      },
    );

    if (confirmed == true) {
      try {
        await DatabaseService().deleteMedication(
          medication.name,
          diagnosisId: medication.diagnosisId,
        );
        _loadMedications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting medication: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting medication: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    const Expanded(child: SizedBox()),
                    Text(
                      'Medications',
                      style: TextStyle(
                        color: Colors.white.themedWith(isDark),
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
                              colorFilter: ColorFilter.mode(
                                Colors.white.themedWith(isDark),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/addmedicine',
                              );
                              if (result == true) {
                                _loadMedications();
                              }
                            },
                            icon: SvgPicture.asset(
                              "assets/images/icon for Medvault/plus.svg",
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.white.themedWith(isDark),
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
                  onChanged: _filterMeds,
                  style: TextStyle(
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search medications...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFB0B0B0).themedWith(isDark),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        "assets/images/icon for Medvault/search.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFFB0B0B0).themedWith(isDark),
                          BlendMode.srcIn,
                        ),
                      ),
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
                            'Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: const Color(0xFF2B2F33).themedWith(isDark),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  medications
                                      .where((m) => !m.isCompleted)
                                      .length
                                      .toString(),
                                  'Active',
                                  const Color(0xFFE8F1FF).themedWith(isDark),
                                  const Color(0xFF277AFF).themedWith(isDark),
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  medications
                                      .where((m) => m.isCompleted)
                                      .length
                                      .toString(),
                                  'Completed',
                                  const Color(0xFFF3E8FF).themedWith(isDark),
                                  const Color(0xFFB794F6).themedWith(isDark),
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  medications
                                      .where(
                                        (m) =>
                                            m.enableReminders && !m.isCompleted,
                                      )
                                      .length
                                      .toString(),
                                  'Reminders',
                                  const Color(0xFFE8F5E9).themedWith(isDark),
                                  const Color(0xFF3AC0A0).themedWith(isDark),
                                  isDark,
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
                  isLoading
                      ? const LoadingAnimation(size: 150)
                      : _filteredMeds.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey.themedWith(isDark),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No medications added yet.'
                                    : 'No results found',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF6C7278,
                                  ).themedWith(isDark),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _filteredMeds
                              .map((m) => _buildMedicationCard(m, isDark))
                              .toList(),
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
    bool isDark,
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
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Inter',
              color: const Color(0xFF6C7278).themedWith(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication, bool isDark) {
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
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            '/medDetail',
            arguments: medication,
          );
          _loadMedications();
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
                      color: const Color(
                        0xFF277AFF,
                      ).themedWith(isDark).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/icon for Medvault/pill.svg",
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF277AFF).themedWith(isDark),
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${medication.dosage} • ${medication.frequency}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: const Color(
                                        0xFF6C7278,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                ],
                              ),
                              if (medication.enableReminders)
                                SvgPicture.asset(
                                  "assets/images/icon for Medvault/bell.svg",
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    const Color(0xFF3AC0A0).themedWith(isDark),
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
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF6C7278).themedWith(isDark),
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
                  // Completed Tag (Green)
                  if (medication.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F1).themedWith(isDark),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF3AC0A0).themedWith(isDark),
                        ),
                      ),
                    ),
                  // Diagnosis Tag (Gray)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5).themedWith(isDark),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      medication.diagnosisId ?? 'General',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF6C7278).themedWith(isDark),
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
                      color: Colors.white.themedWith(isDark),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0).themedWith(isDark),
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
                          colorFilter: ColorFilter.mode(
                            const Color(0xFF6C7278).themedWith(isDark),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medication.frequency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF6C7278).themedWith(isDark),
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
                color: const Color(0xFFE0E0E0).themedWith(isDark),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _deleteMedication(medication),
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

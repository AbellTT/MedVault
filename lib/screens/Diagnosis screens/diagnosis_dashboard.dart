import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/services/database_service.dart';
import 'package:app/screens/dashboard flow/dashboard_nav_bar.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:app/utils/color_extensions.dart';

class DiagnosisDashboard extends StatefulWidget {
  const DiagnosisDashboard({super.key});

  @override
  State<DiagnosisDashboard> createState() => _DiagnosisDashboardState();
}

class _DiagnosisDashboardState extends State<DiagnosisDashboard> {
  final searchController = TextEditingController();

  // Dashboard data
  List<DiagnosisItem> diagnoses = [];
  List<DiagnosisItem> _filteredDiagnoses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate from cache if available to avoid flicker
    final cache = DatabaseService.cachedDiagnoses;
    if (cache != null) {
      diagnoses = cache;
      _filteredDiagnoses = cache;
      isLoading = false;
    }
    _loadDiagnosisData();
  }

  Future<void> _loadDiagnosisData() async {
    if (diagnoses.isEmpty) {
      setState(() => isLoading = true);
    }
    try {
      final fetchedDiagnoses = await DatabaseService().getDiagnoses();
      setState(() {
        diagnoses = fetchedDiagnoses;
        _filteredDiagnoses = fetchedDiagnoses;
        isLoading = false;
      });
      // Re-apply filter if search is not empty
      if (searchController.text.isNotEmpty) {
        _filterDiagnoses(searchController.text);
      }
    } catch (e) {
      debugPrint('Error loading diagnoses: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterDiagnoses(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() => _filteredDiagnoses = diagnoses);
      return;
    }

    setState(() {
      _filteredDiagnoses = diagnoses.where((d) {
        return d.title.toLowerCase().contains(trimmedQuery) ||
            d.description.toLowerCase().contains(trimmedQuery);
      }).toList();
    });
  }

  Future<void> _deleteDiagnosis(String diagnosisName) async {
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
            'Delete Diagnosis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B2F33).themedWith(isDark),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$diagnosisName"? This will also delete all associated documents and notes.',
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
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6C7278).themedWith(isDark),
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
        );
      },
    );

    if (confirmed == true) {
      setState(() => isLoading = true);
      try {
        await DatabaseService().deleteDiagnosis(diagnosisName);
        await _loadDiagnosisData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diagnosis deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting diagnosis: $e');
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting diagnosis: $e')),
          );
        }
      }
    }
  }

  // Calculate summary statistics
  int get totalCount => diagnoses.length;
  int get managedCount =>
      diagnoses.where((d) => d.status == DiagnosisStatus.managed).length;
  int get ongoingCount =>
      diagnoses.where((d) => d.status == DiagnosisStatus.ongoing).length;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ).themedWith(isDark),
      body: Column(
        children: [
          _buildHeader(isDark),

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section - Wrapped in Card
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
                    color: const Color.fromRGBO(
                      255,
                      255,
                      255,
                      1,
                    ).themedWith(isDark),
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
                                  totalCount.toString(),
                                  'Total',
                                  const Color.fromARGB(
                                    118,
                                    232,
                                    241,
                                    255,
                                  ).themedWith(isDark),
                                  const Color(
                                    0xFF277AFF,
                                  ).themedWith(isDark), // Blue border
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  managedCount.toString(),
                                  'Managed',
                                  const Color.fromARGB(
                                    118,
                                    232,
                                    255,
                                    241,
                                  ).themedWith(isDark),
                                  const Color(
                                    0xFF4CAF50,
                                  ).themedWith(isDark), // Green border
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  ongoingCount.toString(),
                                  'Ongoing',
                                  const Color.fromARGB(
                                    118,
                                    255,
                                    243,
                                    216,
                                  ).themedWith(isDark),
                                  const Color(
                                    0xFFFF9800,
                                  ).themedWith(isDark), // Orange border
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Diagnosis Items List - Dynamic rendering
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: LoadingAnimation(size: 150),
                    )
                  else if (_filteredDiagnoses.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            searchController.text.isEmpty
                                ? Icons.folder_open_outlined
                                : Icons.search_off_outlined,
                            size: 48,
                            color: Colors.grey.themedWith(isDark),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'No Diagnosis yet'
                                : 'No results found',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filteredDiagnoses.map(
                      (diagnosis) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDiagnosisItem(diagnosis, isDark),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardNavigationBar(selectedIndex: 3),
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
              color: _getNumberColor(label),
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

  Color _getNumberColor(String label) {
    switch (label) {
      case 'Total':
        return const Color(0xFF277AFF);
      case 'Managed':
        return const Color(0xFF4CAF50);
      case 'Ongoing':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF6C7278);
    }
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF277AFF).themedWith(isDark),
      ),
      child: Column(
        children: [
          // Top Bar with back button, title, and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24), // Spacer instead of back button
              Text(
                'Diagnosis',
                style: TextStyle(
                  color: Colors.white.themedWith(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/addDiagnosis');
                  _loadDiagnosisData();
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white.themedWith(isDark),
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar
          TextField(
            controller: searchController,
            onChanged: _filterDiagnoses,
            style: TextStyle(
              color: const Color(0xFF2B2F33).themedWith(isDark),
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search diagnosis...',
              hintStyle: TextStyle(
                color: const Color(0xFFB0B0B0).themedWith(isDark),
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
              prefixIcon: Icon(
                Icons.search,
                color: const Color(0xFFB0B0B0).themedWith(isDark),
              ),
              filled: true,
              fillColor: Colors.white.themedWith(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisItem(DiagnosisItem diagnosis, bool isDark) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(178, 212, 212, 212).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/diagnosisDetail',
          arguments: diagnosis,
        ),
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color.fromARGB(151, 39, 122, 255).withAlpha(30),
        highlightColor: const Color.fromARGB(151, 39, 122, 255).withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF).themedWith(isDark),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icon for Medvault/filetext.svg",
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF277AFF).themedWith(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF2B2F33).themedWith(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          diagnosis.description,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF6C7278).themedWith(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete and Arrow Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _deleteDiagnosis(diagnosis.title),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: const Color(0xFFB0B4B8).themedWith(isDark),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: diagnosis.statusBackgroundColor.themedWith(isDark),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: diagnosis.statusBorderColor.themedWith(isDark),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      diagnosis.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: diagnosis.statusTextColor.themedWith(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: diagnosis.severityColor.themedWith(isDark),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        diagnosis.severityText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: diagnosis.severityColor.themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Info (Date, Docs, Meds)
              Row(
                children: [
                  // Calendar Icon
                  SvgPicture.asset(
                    "assets/images/icon for Medvault/calendar.svg",
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF3AC0A0),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    diagnosis.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF6C7278).themedWith(isDark),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Files Icon
                  SvgPicture.asset(
                    "assets/images/icon for Medvault/filetext.svg",
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF6C7278).themedWith(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    diagnosis.formattedDocsCount,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF6C7278).themedWith(isDark),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Pills Icon
                  SvgPicture.asset(
                    "assets/images/icon for Medvault/pill.svg",
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF277AFF).themedWith(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    diagnosis.formattedMedsCount,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF6C7278).themedWith(isDark),
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

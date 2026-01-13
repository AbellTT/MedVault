import 'package:app/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/dashboard flow/dashboard_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard_menu.dart';
import 'package:app/models/user_profile.dart';
import 'package:app/models/vital_stats.dart';
import 'package:app/models/medication.dart';
import 'package:app/models/appointment.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<bool> toggleDarkMode;
  const DashboardScreen({super.key, required this.toggleDarkMode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isMenuOpen = false;

  // Dashboard data variables
  UserProfile? userProfile;
  String userEmail = '';
  VitalStats? vitalStats;
  Appointment? nextAppointment;
  List<Medication> medicationReminders = [];
  List<Medication> _filteredMedicationReminders = [];
  List<_Dose> _displayDoses = [];
  List<_Dose> _filteredDisplayDoses = [];
  List<DiagnosisItem> diagnoses = [];
  List<DiagnosisItem> _filteredDiagnoses = [];

  // Data for global search
  List<Appointment> allAppointments = [];
  List<Medication> allMedications = [];
  List<_GlobalSearchResult> _globalSearchResults = [];

  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final data = await DatabaseService().getUserData();

    if (data != null && mounted) {
      final personal = data['personal_info'] ?? {};
      final health = data['health_metrics'] ?? {};
      final account = data['account_info'] ?? {};

      setState(() {
        // Calculate BMI: weight / (height / 100)^2
        String calculatedBmi = '--';
        final double? h = double.tryParse(
          health['height_cm']?.toString() ?? '',
        );
        final double? w = double.tryParse(
          health['weight_kg']?.toString() ?? '',
        );
        if (h != null && w != null && h > 0) {
          final double bmiVal = w / ((h / 100) * (h / 100));
          calculatedBmi = bmiVal.toStringAsFixed(1);
        }

        userProfile = UserProfile(
          firstName: personal['first_name'] ?? 'MedVault',
          lastName: personal['last_name'] ?? 'User',
          lastCheckUp: personal['last_checkup_date'] != null
              ? DateTime.parse(personal['last_checkup_date'])
              : null,
          profilePictureUrl: account['profile_picture'],
        );

        vitalStats = VitalStats(
          height: health['height_cm']?.toString() ?? '--',
          weight: health['weight_kg']?.toString() ?? '--',
          bmi: calculatedBmi,
          bloodPressure: health['blood_pressure'] ?? '--/--',
          bloodSugar: health['blood_sugar']?.toString() ?? '--',
        );

        userEmail = account['email'] ?? '';

        isLoading = false;
      });

      // Fetch Appointments, Meds and Diagnoses in background
      _fetchDashboardSecondaryData();
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDashboardSecondaryData() async {
    try {
      final appts = await DatabaseService().getAppointments();
      final meds = await DatabaseService().getAllUserMedications();
      final diags = await DatabaseService().getDiagnoses();

      if (mounted) {
        setState(() {
          allAppointments = appts;
          allMedications = meds;

          // 1. Single nearest uncompleted appointment
          final now = DateTime.now();
          final upcomingAppts = appts.where((a) {
            if (a.status != 'Upcoming') return false;
            final apptDateTime = DateTime(
              a.date.year,
              a.date.month,
              a.date.day,
              a.startTime.hour,
              a.startTime.minute,
            );
            return apptDateTime.isAfter(now);
          }).toList();

          if (upcomingAppts.isNotEmpty) {
            // Already sorted by DatabaseService, but let's be sure
            upcomingAppts.sort((a, b) {
              int dateComp = a.date.compareTo(b.date);
              if (dateComp != 0) return dateComp;
              return (a.startTime.hour * 60 + a.startTime.minute).compareTo(
                b.startTime.hour * 60 + b.startTime.minute,
              );
            });
            nextAppointment = upcomingAppts.first;
          } else {
            nextAppointment = null;
          }

          diagnoses = diags;

          medicationReminders = meds
              .where((m) => !m.isCompleted && m.enableReminders)
              .toList();
          _filteredMedicationReminders = medicationReminders;
          _updateDisplayDoses();
          _filterResults(_searchController.text);
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard secondary data: $e');
    }
  }

  void _filterResults(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _filteredDiagnoses = diagnoses;
        _filteredDisplayDoses = _displayDoses;
        _filteredMedicationReminders = medicationReminders;
        _globalSearchResults = [];
      });
      return;
    }

    // 1. Filter diagnoses
    final matchedDiagnoses = diagnoses
        .where(
          (d) =>
              d.title.toLowerCase().contains(trimmedQuery) ||
              d.description.toLowerCase().contains(trimmedQuery),
        )
        .toList();

    // 2. Filter display doses
    final matchedDoses = _displayDoses
        .where(
          (d) =>
              d.med.name.toLowerCase().contains(trimmedQuery) ||
              d.med.dosage.toLowerCase().contains(trimmedQuery),
        )
        .toList();

    // 3. Filter medication reminders
    final matchedMedicationReminders = medicationReminders
        .where(
          (m) =>
              m.name.toLowerCase().contains(trimmedQuery) ||
              m.dosage.toLowerCase().contains(trimmedQuery) ||
              m.instructions.toLowerCase().contains(trimmedQuery),
        )
        .toList();

    // 4. Global search results aggregation
    final List<_GlobalSearchResult> globalResults = [];

    // Appointments (Global)
    for (var a in allAppointments) {
      if (a.doctorName.toLowerCase().contains(trimmedQuery) ||
          a.specialty.toLowerCase().contains(trimmedQuery) ||
          a.location.toLowerCase().contains(trimmedQuery)) {
        globalResults.add(
          _GlobalSearchResult(
            title: a.doctorName,
            subtitle: "${a.specialty} • ${a.formattedDate}",
            type: _SearchResultType.appointment,
            originalObject: a,
          ),
        );
      }
    }

    // Medications (Global)
    for (var m in allMedications) {
      if (m.name.toLowerCase().contains(trimmedQuery) ||
          m.dosage.toLowerCase().contains(trimmedQuery)) {
        globalResults.add(
          _GlobalSearchResult(
            title: m.name,
            subtitle: "${m.dosage} • ${m.frequency}",
            type: _SearchResultType.medication,
            originalObject: m,
          ),
        );
      }
    }

    // Diagnoses (Global)
    for (var d in diagnoses) {
      if (d.title.toLowerCase().contains(trimmedQuery) ||
          d.description.toLowerCase().contains(trimmedQuery)) {
        globalResults.add(
          _GlobalSearchResult(
            title: d.title,
            subtitle: d.statusText,
            type: _SearchResultType.diagnosis,
            originalObject: d,
          ),
        );
      }
    }

    setState(() {
      _filteredDiagnoses = matchedDiagnoses;
      _filteredDisplayDoses = matchedDoses;
      _filteredMedicationReminders = matchedMedicationReminders;
      _globalSearchResults = globalResults;
    });
  }

  void _updateDisplayDoses() {
    final String todayKey = DateTime.now().toIso8601String().split('T')[0];
    final List<_Dose> allDoses = [];

    for (var med in medicationReminders) {
      for (var time in med.reminderTimes) {
        final bool isTaken = med.takenDoses[todayKey]?.contains(time) ?? false;
        allDoses.add(_Dose(med: med, time: time, isTaken: isTaken));
      }
    }

    if (allDoses.isEmpty) {
      _displayDoses = [];
      return;
    }

    allDoses.sort((a, b) => a.time.compareTo(b.time));

    _Dose? lastTaken;
    _Dose? nextDue;
    final List<_Dose> upcoming = [];

    for (var dose in allDoses) {
      if (dose.isTaken) {
        lastTaken = dose;
      } else {
        if (nextDue == null) {
          nextDue = dose;
        } else {
          upcoming.add(dose);
        }
      }
    }

    final List<_Dose> orderedDoses = [];
    if (lastTaken != null) orderedDoses.add(lastTaken);
    if (nextDue != null) {
      orderedDoses.add(nextDue);
      if (upcoming.isNotEmpty) {
        orderedDoses.add(upcoming.first);
      }
    } else if (orderedDoses.isEmpty && upcoming.isNotEmpty) {
      orderedDoses.add(upcoming.first);
      if (upcoming.length > 1) orderedDoses.add(upcoming[1]);
    }
    _displayDoses = orderedDoses;
    _filteredDisplayDoses = orderedDoses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).themedWith(isDark),
          body: isLoading
              ? const LoadingAnimation()
              : Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVitalStat(context, vitalStats, isDark),
                                const SizedBox(height: 20),
                                _buildNextAppointment(
                                  context,
                                  nextAppointment,
                                  isDark,
                                ),
                                const SizedBox(height: 20),
                                _buildDiagnosis(
                                  context,
                                  _filteredDiagnoses,
                                  isDark,
                                ),
                                const SizedBox(height: 20),
                                _buildMedicationReminder(
                                  context,
                                  _filteredMedicationReminders,
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _buildSearchResultsOverlay(isDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: DashboardNavigationBar(
            selectedIndex: 2,
            onReturn: () => _loadDashboardData(),
          ),
        ),
        // 2) Backdrop overlay — under menu
        if (isMenuOpen)
          GestureDetector(
            onTap: () => setState(() => isMenuOpen = false),
            child: Container(
              color: Colors.black.withAlpha(55).themedWith(isDark),
            ),
          ),
        // 3) Sliding menu — on top
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          left: isMenuOpen ? 0 : -320,
          child: Material(
            // no const, no Scaffold
            color: Colors.white.themedWith(isDark), // menu background
            child: DashboardMenu(
              onClose: () => setState(() => isMenuOpen = false),
              isDarkMode: isDark,
              onDarkModeChanged: (value) {
                // Just toggle the global theme; the rebuild will update the UI
                widget.toggleDarkMode(value);
              },
              firstName: userProfile?.firstName ?? 'MedVault',
              lastName: userProfile?.lastName ?? 'User',
              email: userEmail,
              profilePictureUrl: userProfile?.profilePictureUrl,
              onProfileUpdate: () => _loadDashboardData(),
            ),
          ),
        ),
      ],
    ); // 4) Show bottom navigation ONLY when menu is closed
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF277AFF).themedWith(isDark),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Hamburger Menu and Status Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() => isMenuOpen = true);
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white.themedWith(isDark),
                    size: 35,
                  ),
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    surfaceTintColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(66, 58, 192, 161);
                      }
                      return Colors.transparent;
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 10),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Welcome Section with User Info
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: const Color.fromARGB(
                        190,
                        255,
                        255,
                        255,
                      ).themedWith(isDark),
                    ),
                    borderRadius: BorderRadius.circular(10000),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10000),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child:
                          userProfile?.profilePictureUrl != null &&
                              userProfile!.profilePictureUrl!.startsWith('http')
                          ? Image.network(
                              userProfile!.profilePictureUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color.fromARGB(
                                    255,
                                    107,
                                    164,
                                    255,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color.fromARGB(
                                        255,
                                        107,
                                        164,
                                        255,
                                      ),
                                      child: const Center(
                                        child: LoadingAnimation(),
                                      ),
                                    );
                                  },
                            )
                          : userProfile?.profilePictureUrl != null &&
                                userProfile!.profilePictureUrl!.isNotEmpty
                          ? Image.file(
                              File(userProfile!.profilePictureUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color.fromARGB(
                                    255,
                                    107,
                                    164,
                                    255,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color.fromARGB(255, 107, 164, 255),
                              child: const Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.themedWith(isDark),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      isLoading && userProfile == null
                          ? 'Loading...'
                          : userProfile?.fullName ?? 'User',
                      style: TextStyle(
                        color: Colors.white.themedWith(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      isLoading && userProfile == null
                          ? 'Fetching check-up...'
                          : 'Last check-up: ${userProfile?.formattedLastCheckUp ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.white70.themedWith(isDark),
                        fontSize: 14,
                        fontFamily: 'inter5',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            _buildSearch(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context, bool isDark) {
    return (TextField(
      controller: _searchController,
      onChanged: _filterResults,
      style: TextStyle(color: const Color(0xFF2B2F33).themedWith(isDark)),
      decoration: InputDecoration(
        hintText: "search records, doctors, medications..",
        hintStyle: TextStyle(color: Colors.grey.themedWith(isDark)),
        prefixIcon: Icon(Icons.search, color: Colors.grey.themedWith(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: Colors.white.themedWith(isDark),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: const Color(0xFF277AFF).themedWith(isDark),
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.white.themedWith(isDark),
      ),
    ));
  }

  Widget _buildSearchResultsOverlay(bool isDark) {
    final trimmedQuery = _searchController.text.trim();
    if (trimmedQuery.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.themedWith(isDark),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 20),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB).themedWith(isDark),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                "Search Results (${_globalSearchResults.length})",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.themedWith(isDark),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _globalSearchResults.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: Colors.grey.themedWith(isDark),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No matches found",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.grey.themedWith(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _globalSearchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _globalSearchResults[index];
                        IconData icon;
                        Color iconColor;

                        switch (result.type) {
                          case _SearchResultType.appointment:
                            icon = Icons.calendar_today_rounded;
                            iconColor = const Color(0xFF277AFF);
                            break;
                          case _SearchResultType.medication:
                            icon = Icons.medication_rounded;
                            iconColor = const Color(0xFF4CAF50);
                            break;
                          case _SearchResultType.diagnosis:
                            icon = Icons.description_rounded;
                            iconColor = const Color(0xFFFF9800);
                            break;
                        }

                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: iconColor, size: 20),
                          ),
                          title: Text(
                            result.title,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2B2F33).themedWith(isDark),
                            ),
                          ),
                          subtitle: Text(
                            result.subtitle,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.grey.themedWith(isDark),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          onTap: () {
                            // Clear search and navigate
                            _searchController.clear();
                            _filterResults("");

                            switch (result.type) {
                              case _SearchResultType.appointment:
                                Navigator.pushNamed(
                                  context,
                                  '/appointmentDetail',
                                  arguments: result.originalObject,
                                );
                                break;
                              case _SearchResultType.medication:
                                Navigator.pushNamed(
                                  context,
                                  '/medDetail',
                                  arguments: result.originalObject,
                                );
                                break;
                              case _SearchResultType.diagnosis:
                                Navigator.pushNamed(
                                  context,
                                  '/diagnosisDetail',
                                  arguments: result.originalObject,
                                );
                                break;
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalStat(
    BuildContext context,
    VitalStats? vitalStats,
    bool isDark,
  ) {
    return (Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(178, 212, 212, 212).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: isLoading && vitalStats == null
            ? const SizedBox(height: 200, child: LoadingAnimation(size: 150))
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vital Stats",
                        style: TextStyle(
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/profile',
                        ).then((_) => _loadDashboardData()),
                        icon: Icon(
                          Icons.edit,
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    childAspectRatio: 1.3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(
                        'Height',
                        vitalStats?.formattedHeight ?? '--',
                        Icons.height,
                        const Color(0xFF277AFF),
                        const Color.fromARGB(26, 39, 122, 255),
                        '',
                        isDark,
                      ),
                      _buildStatCard(
                        'Weight',
                        vitalStats?.formattedWeight ?? '--',
                        Icons.monitor_weight,
                        const Color(0xFF3AC0A0),
                        const Color.fromARGB(26, 58, 192, 161),
                        '',
                        isDark,
                      ),
                      _buildStatCard(
                        'BMI',
                        vitalStats?.bmi ?? '--',
                        Icons.insights,
                        const Color(0xFF277AFF),
                        const Color.fromARGB(26, 39, 122, 255),
                        '',
                        isDark,
                      ),
                      _buildStatCard(
                        'BP',
                        vitalStats?.formattedBP ?? '--/--',
                        Icons.monitor_heart,
                        const Color(0xFF3AC0A0),
                        const Color.fromARGB(26, 58, 192, 161),
                        'mmHg',
                        isDark,
                      ),
                      _buildStatCard(
                        'Sugar',
                        vitalStats?.formattedSugar ?? '--',
                        Icons.bloodtype,
                        const Color(0xFF277AFF),
                        const Color.fromARGB(26, 39, 122, 255),
                        '',
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    ));
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
    String unit,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: const Color(0x086C7278).themedWith(isDark),
        border: Border.all(
          color: const Color.fromARGB(21, 0, 0, 0).themedWith(isDark),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'inter',
                color: const Color.fromARGB(
                  255,
                  96,
                  102,
                  107,
                ).themedWith(isDark),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$value ',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'inter',
                      color: const Color.fromARGB(
                        255,
                        88,
                        92,
                        97,
                      ).themedWith(isDark),
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: unit,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'inter',
                        color: const Color.fromARGB(
                          255,
                          88,
                          92,
                          97,
                        ).themedWith(isDark),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointment(
    BuildContext context,
    Appointment? nextAppointment,
    bool isDark,
  ) {
    return InkWell(
      onTap: () async {
        if (nextAppointment != null) {
          final result = await Navigator.pushNamed(
            context,
            '/appointmentDetail',
            arguments: nextAppointment,
          );
          if (result == true) {
            _loadDashboardData();
          }
        } else {
          final result = await Navigator.pushNamed(context, '/addAppointment');
          if (result == true) {
            _loadDashboardData();
          }
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color.fromARGB(178, 212, 212, 212).themedWith(isDark),
            width: 1,
          ),
        ),
        color: const Color(0xFF3AC0A0).themedWith(isDark),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Next Appointment",
                    style: TextStyle(
                      color: Colors.white.themedWith(isDark),
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (nextAppointment != null) {
                        Navigator.pushNamed(context, '/appointmentsDashboard');
                      } else {
                        Navigator.pushNamed(context, '/addAppointment');
                      }
                    },
                    icon: Icon(
                      nextAppointment != null
                          ? Icons.calendar_today
                          : Icons.add,
                      color: Colors.white.themedWith(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: const Color.fromARGB(35, 255, 255, 255),
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: nextAppointment != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Doctor & Type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nextAppointment.doctorName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          color: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        nextAppointment.specialty,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          color: Colors.white.themedWith(
                                            isDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    nextAppointment.linkedDiagnosis,
                                    style: TextStyle(
                                      color: Colors.white.themedWith(isDark),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Date
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Colors.white.themedWith(isDark),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  nextAppointment.formattedDate,
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

                            // Time (No Pill)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.white.themedWith(isDark),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  nextAppointment.formatTime(context),
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

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.themedWith(isDark),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nextAppointment.location,
                                    style: TextStyle(
                                      color: Colors.white.themedWith(isDark),
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy_outlined,
                                  color: Colors.white.themedWith(isDark),
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No appointment yet",
                                  style: TextStyle(
                                    color: Colors.white.themedWith(isDark),
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              if (nextAppointment != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color.fromARGB(
                            66,
                            58,
                            192,
                            161,
                          ).themedWith(isDark);
                        }
                        return Colors.white.withValues(alpha: 0.25);
                      }),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/appointmentsDashboard');
                    },
                    child: Text(
                      "View All Appointments",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.themedWith(isDark),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosis(
    BuildContext context,
    List<DiagnosisItem> diagnoses,
    bool isDark,
  ) {
    return (Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(178, 212, 212, 212).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Diagnosis",
                  style: TextStyle(
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color(
                          0xFF1E5ED8,
                        ); // darker blue when pressed
                      }
                      return const Color(
                        0xFF277AFF,
                      ).themedWith(isDark); // your normal blue
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addDiagnosis');
                  },
                  child: Text(
                    "+ Add",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white.themedWith(isDark),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_filteredDiagnoses.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                child: Column(
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.medical_information_outlined
                          : Icons.search_off_outlined,
                      size: 48,
                      color: Colors.grey.themedWith(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? "No diagnoses yet"
                          : "No results matched your search",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.themedWith(isDark),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._filteredDiagnoses
                  .take(3)
                  .map(
                    (diagnosis) => Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          9,
                          108,
                          114,
                          120,
                        ).themedWith(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB).themedWith(isDark),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE8F1FF,
                                  ).themedWith(isDark),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  "assets/images/icon for Medvault/filetext.svg",
                                  width: 10,
                                  height: 10,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF277AFF),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diagnosis.title,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Diagnosed: ${diagnosis.formattedDate}",
                                    style: TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: 11,
                                      color: const Color(
                                        0xFF6C7278,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: diagnosis.statusBackgroundColor
                                          .themedWith(isDark),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: diagnosis.statusBorderColor
                                            .themedWith(isDark),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      diagnosis.statusText,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: diagnosis.statusTextColor
                                            .themedWith(isDark),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: const Color(0xFFB0B4B8).themedWith(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ));
  }

  Widget _buildMedicationReminder(
    BuildContext context,
    List<Medication> medicationReminders,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color.fromARGB(178, 212, 212, 212).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Medication Reminders",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF2B2F33).themedWith(isDark),
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            if (_filteredDisplayDoses.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                child: Column(
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.medication_outlined
                          : Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey.themedWith(isDark),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? "No items scheduled for today"
                          : "No results matched your search",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.themedWith(isDark),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._filteredDisplayDoses.map((dose) {
                final bool isNextDue =
                    _displayDoses.isNotEmpty &&
                    _filteredDisplayDoses.any((d) => !d.isTaken) &&
                    dose ==
                        _filteredDisplayDoses.firstWhere(
                          (d) => !d.isTaken,
                          orElse: () => dose,
                        );
                final bool isTakenToday = dose.isTaken;
                final reminder = dose.med;
                final reminderTime = dose.time;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (isTakenToday
                                  ? const Color(0xFFE8F5F1)
                                  : const Color(0xFFF0F4FF))
                              .themedWith(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            (isTakenToday
                                    ? const Color(0xFF3AC0A0)
                                    : Colors.transparent)
                                .themedWith(isDark),
                        width: isTakenToday ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    (isTakenToday
                                            ? const Color(
                                                0xFF3AC0A0,
                                              ).themedWith(isDark)
                                            : const Color(
                                                0xFF277AFF,
                                              ).themedWith(isDark))
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(
                                isTakenToday
                                    ? "assets/images/icon for Medvault/checkcircle2.svg"
                                    : "assets/images/icon for Medvault/pill.svg",
                                width: 10,
                                height: 10,
                                colorFilter: ColorFilter.mode(
                                  (isTakenToday
                                          ? const Color(0xFF3AC0A0)
                                          : const Color(0xFF277AFF))
                                      .themedWith(isDark),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.name,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          (isTakenToday
                                                  ? Colors.grey
                                                  : const Color(0xFF2B2F33))
                                              .themedWith(isDark),
                                    ),
                                  ),
                                  Text(
                                    reminder.dosage,
                                    style: TextStyle(
                                      fontFamily: 'inter',
                                      fontSize: 10,
                                      color:
                                          (isTakenToday
                                                  ? Colors.grey
                                                  : Colors.black54)
                                              .themedWith(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              size: 15,
                              color:
                                  (isTakenToday
                                          ? Colors.grey
                                          : const Color(0xFF2B2F33))
                                      .themedWith(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              reminderTime,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color:
                                    (isTakenToday
                                            ? Colors.grey
                                            : const Color(0xFF2B2F33))
                                        .themedWith(isDark),
                              ),
                            ),
                          ],
                        ),
                        if (isNextDue) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: const Color.fromARGB(
                              97,
                              39,
                              122,
                              255,
                            ).themedWith(isDark),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                await DatabaseService()
                                    .toggleMedicationTakenToday(
                                      reminder,
                                      reminderTime,
                                      true,
                                    );
                                _loadDashboardData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF38C9A9,
                                ).themedWith(isDark),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Text(
                                "Mark as Taken",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white.themedWith(isDark),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),

            // Only show View All Reminders button if there are medications
            if (medicationReminders.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/medReminders');
                  },
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    surfaceTintColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(
                          65,
                          133,
                          133,
                          133,
                        ); // darker blue when pressed
                      }
                      return const Color.fromARGB(
                        45,
                        180,
                        180,
                        180,
                      ).themedWith(isDark); // your normal blue
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 0),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const BorderSide(
                          color: Color.fromARGB(
                            150,
                            133,
                            133,
                            133,
                          ), // slightly darker when pressed
                          width: 1.2,
                        );
                      }
                      return const BorderSide(
                        color: Color.fromARGB(
                          178,
                          212,
                          212,
                          212,
                        ), // normal border
                        width: 1,
                      );
                    }),
                  ),
                  child: Text(
                    "View All Reminders >",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.black54.themedWith(isDark),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _SearchResultType { appointment, medication, diagnosis }

class _GlobalSearchResult {
  final String title;
  final String subtitle;
  final _SearchResultType type;
  final dynamic originalObject;

  _GlobalSearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.originalObject,
  });
}

class _Dose {
  final Medication med;
  final String time;
  final bool isTaken;

  _Dose({required this.med, required this.time, required this.isTaken});
}

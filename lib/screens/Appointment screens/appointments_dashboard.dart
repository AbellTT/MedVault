import 'package:app/models/appointment.dart';
import 'package:app/screens/dashboard%20flow/dashboard_nav_bar.dart';
import 'package:app/services/database_service.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';

class AppointmentsDashboard extends StatefulWidget {
  const AppointmentsDashboard({super.key});

  @override
  State<AppointmentsDashboard> createState() => _AppointmentsDashboardState();
}

class _AppointmentsDashboardState extends State<AppointmentsDashboard> {
  final TextEditingController _searchController = TextEditingController();

  // Sample appointment data
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final data = await DatabaseService().getAppointments();
      if (mounted) {
        setState(() {
          _appointments = data;
          _filteredAppointments = data;
          _isLoading = false;
        });
        // Re-apply filter if search is not empty
        if (_searchController.text.isNotEmpty) {
          _filterAppointments(_searchController.text);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterAppointments(String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      setState(() => _filteredAppointments = _appointments);
      return;
    }

    setState(() {
      _filteredAppointments = _appointments.where((a) {
        return a.doctorName.toLowerCase().contains(trimmedQuery) ||
            a.specialty.toLowerCase().contains(trimmedQuery) ||
            a.status.toLowerCase().contains(trimmedQuery) ||
            a.location.toLowerCase().contains(trimmedQuery);
      }).toList();
    });
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
            ), // Blue Header
            child: Column(
              children: [
                // Top Bar
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Text(
                      'Appointments',
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
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/addAppointment',
                              );
                              if (result == true) {
                                _fetchAppointments();
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
                  onChanged: _filterAppointments,
                  style: TextStyle(
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
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
                  // Summary Section
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFFD4D4D4).themedWith(isDark),
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
                            'Overview',
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
                                  _appointments.length.toString(),
                                  'Total',
                                  const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark).withValues(alpha: 0.12),
                                  const Color(0xFF3AC0A0).themedWith(isDark),
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  _appointments
                                      .where((a) => a.status == 'Upcoming')
                                      .length
                                      .toString(),
                                  'Upcoming',
                                  const Color(
                                    0xFF277AFF,
                                  ).themedWith(isDark).withValues(alpha: 0.12),
                                  const Color(0xFF277AFF).themedWith(isDark),
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  _appointments
                                      .where((a) => a.status == 'Completed')
                                      .length
                                      .toString(),
                                  'Completed',
                                  const Color(
                                    0xFF48BB78,
                                  ).themedWith(isDark).withValues(alpha: 0.12),
                                  const Color(0xFF48BB78).themedWith(isDark),
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Appointments List
                  _isLoading
                      ? const LoadingAnimation()
                      : _filteredAppointments.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _searchController.text.isEmpty
                                  ? SvgPicture.asset(
                                      'assets/images/icon for Medvault/calendar.svg',
                                      width: 48,
                                      height: 48,
                                      colorFilter: ColorFilter.mode(
                                        Colors.grey.themedWith(isDark),
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: Colors.grey.themedWith(isDark),
                                    ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? "No appointments found"
                                    : "No results found",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(
                              _filteredAppointments[index],
                              isDark,
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardNavigationBar(selectedIndex: 0),
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

  Widget _buildAppointmentCard(Appointment appointment, bool isDark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF3AC0A0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: const Color(0xFF3AC0A0).themedWith(isDark), // Green Card
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/appointmentDetail',
            arguments: appointment,
          );
          // Reload if edited or deleted
          if (result == true) {
            _fetchAppointments();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.themedWith(isDark).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Doctor Info & Type Pill
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
                              fontSize: 16, // Reduced from 18 slightly
                              fontFamily: 'Poppins',
                              color: Colors.white.themedWith(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            appointment.specialty,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Poppins', // Changed to Poppins
                              color: Colors.white.themedWith(
                                isDark,
                              ), // Pure white
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Diagnosis/Status Pills
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .themedWith(isDark)
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment.linkedDiagnosis,
                            style: TextStyle(
                              color: Colors.white.themedWith(isDark),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (appointment.status == 'Completed') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .themedWith(isDark)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white.themedWith(isDark),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.white.themedWith(isDark),
                                    fontSize: 11,
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

                // Time
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

                // Location
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

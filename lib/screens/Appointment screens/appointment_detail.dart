import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:app/models/appointment.dart';
import 'package:app/services/database_service.dart';

class AppointmentDetail extends StatelessWidget {
  const AppointmentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final appointment =
        ModalRoute.of(context)!.settings.arguments as Appointment;

    final String doctorName = appointment.doctorName;
    final String specialty = appointment.specialty;
    final String appointmentDate = appointment.formattedDate;
    final String appointmentTime = appointment.formatTime(context);
    final String location = appointment.location;
    final String reason = appointment.reason;
    final String notes = appointment.notes;
    final String linkedDiagnosis = appointment.linkedDiagnosis;

    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        children: [
          // Header with Edit Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Row(
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
                    'Appointment Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.themedWith(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/appointmentEdit',
                      arguments: appointment,
                    );
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
                IconButton(
                  onPressed: () => _deleteAppointment(context, appointment),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.white.themedWith(isDark),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info Card
                  _buildDoctorCard(context, doctorName, specialty, isDark),
                  const SizedBox(height: 24),

                  // Linked Diagnosis Section
                  _buildDetailSection(
                    context: context,
                    icon: 'activity',
                    title: 'Linked Diagnosis',
                    isDark: isDark,
                    content: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF3AC0A0,
                        ).themedWith(isDark).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF3AC0A0).themedWith(isDark),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        linkedDiagnosis,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3AC0A0).themedWith(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Schedule Section
                  _buildDetailSection(
                    context: context,
                    icon: 'calendar',
                    title: 'Date & Time',
                    isDark: isDark,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointmentDate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF2B2F33).themedWith(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointmentTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: const Color(0xFF6C7278).themedWith(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location Section
                  _buildDetailSection(
                    context: context,
                    icon: 'mappin',
                    title: 'Location',
                    isDark: isDark,
                    content: Text(
                      location,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reason Section
                  _buildDetailSection(
                    context: context,
                    icon: 'filetext',
                    title: 'Reason for Visit',
                    isDark: isDark,
                    content: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes Section
                  _buildDetailSection(
                    context: context,
                    icon:
                        'trendingup', // Using an available icon as notes placeholder
                    title: 'Additional Notes',
                    isDark: isDark,
                    content: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    String name,
    String specialty,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFF3AC0A0,
        ).themedWith(isDark).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFF3AC0A0,
          ).themedWith(isDark).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF3AC0A0).themedWith(isDark),
            child: const Text('👨🏻‍⚕️', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                    color: const Color(0xFF3AC0A0).themedWith(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required BuildContext context,
    required String icon,
    required String title,
    required Widget content,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              "assets/images/icon for Medvault/$icon.svg",
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                const Color(0xFF3AC0A0).themedWith(isDark),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: const Color(0xFF2B2F33).themedWith(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.themedWith(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0).themedWith(isDark),
              width: 1,
            ),
          ),
          child: content,
        ),
      ],
    );
  }

  Future<void> _deleteAppointment(
    BuildContext context,
    Appointment appointment,
  ) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.themedWith(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Appointment?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B2F33).themedWith(isDark),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this appointment? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278).themedWith(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C7278).themedWith(isDark),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.red.themedWith(isDark),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await DatabaseService().deleteAppointment(appointment);
      if (context.mounted) {
        Navigator.pop(context, true); // Close detail and signal refresh
      }
    }
  }
}

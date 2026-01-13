import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import '../../models/medication.dart';
import '../../services/database_service.dart';
import '../../widgets/loading_animation.dart';

class AlarmRingingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingingScreen({super.key, required this.alarmSettings});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  Medication? medication;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    final title = widget.alarmSettings.notificationSettings.title;
    // title format is "Time for [medName]" or "⏰ MedVault Test Alarm"
    String medName = '';
    if (title.contains('Time for ')) {
      medName = title.replaceFirst('Time for ', '');
    } else if (title.contains('Alarm Test')) {
      medName = 'Test Medication';
    }

    if (medName.isNotEmpty) {
      final meds = await DatabaseService().getAllUserMedications();
      try {
        medication = meds.firstWhere((m) => m.name == medName);
      } catch (e) {
        // Fallback or handle test alarm
        if (medName == 'Test Medication') {
          medication = Medication(
            id: 'test',
            name: 'Test Medication',
            dosage: '1 Pill',
            frequency: 'Once',
            instructions: 'This is a test alarm to verify functionality.',
          );
        }
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleTaken() async {
    if (medication != null && medication!.id != 'test') {
      // Find the reminder time that triggered this alarm
      // reminderTimes are strings like "08:00 AM"
      final scheduledTime = widget.alarmSettings.dateTime;
      final hour = scheduledTime.hour;
      final minute = scheduledTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr =
          "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";

      // Match with meditation.reminderTimes (some might be "8:00 AM" or "08:00 AM")
      String? matchedTime;
      for (var t in medication!.reminderTimes) {
        if (t.replaceAll(' ', '') == timeStr.replaceAll(' ', '') ||
            t.replaceAll(' ', '') ==
                timeStr.replaceFirst('0', '').replaceAll(' ', '')) {
          matchedTime = t;
          break;
        }
      }

      // If no exact match (snoozed or something), use the first one as fallback
      matchedTime ??= medication!.reminderTimes.first;

      await DatabaseService().toggleMedicationTakenToday(
        medication!,
        matchedTime,
        true,
      );
    }

    await Alarm.stop(widget.alarmSettings.id);
    SystemNavigator.pop();
  }

  Future<void> _handleSnooze() async {
    final now = DateTime.now();
    await Alarm.stop(widget.alarmSettings.id);

    // Schedule a one-time snooze alarm in 10 mins
    final snoozeSettings = AlarmSettings(
      id: widget.alarmSettings.id + 1000, // Unique offset for snooze
      dateTime: now.add(const Duration(minutes: 10)),
      assetAudioPath: 'assets/audio/alert.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.5,
      fadeDuration: widget.alarmSettings.fadeDuration,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: 'Snoozed: ${medication?.name ?? "Medication"}',
        body: 'Click to open and take your medication.',
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: snoozeSettings);

    SystemNavigator.pop();
  }

  Future<void> _handleComplete() async {
    if (medication != null && medication!.id != 'test') {
      await DatabaseService().completeMedication(medication!);
    }
    await Alarm.stop(widget.alarmSettings.id);
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white.themedWith(isDark),
        body: const Center(child: LoadingAnimation()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Logo & App Name
              Column(
                children: [
                  Image.asset(
                    'assets/images/icon (1).png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MedVault',
                    style: TextStyle(
                      color: const Color(0xFF277AFF).themedWith(isDark),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Medication Info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.themedWith(isDark),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .themedWith(isDark)
                          .withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF0F0F0).themedWith(isDark),
                  ),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/icon for Medvault/pill.svg',
                      width: 48,
                      height: 48,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF277AFF).themedWith(isDark),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      medication?.name ?? 'Unknown Medication',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dosage: ${medication?.dosage ?? "Not specified"}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                        color: const Color(0xFF6C7278).themedWith(isDark),
                      ),
                    ),
                    if (medication?.instructions.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        medication!.instructions,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF2B2F33).themedWith(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              Column(
                children: [
                  // Taken Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _handleTaken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF3AC0A0,
                        ).themedWith(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Mark as Taken',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.themedWith(isDark),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Snooze Button
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: OutlinedButton(
                            onPressed: _handleSnooze,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color(
                                  0xFFE0E0E0,
                                ).themedWith(isDark),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Snooze',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF6C7278,
                                ).themedWith(isDark),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Complete Button
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: TextButton(
                            onPressed: _handleComplete,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF5F5F5,
                              ).themedWith(isDark),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

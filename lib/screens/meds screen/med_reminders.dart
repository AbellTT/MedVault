import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:app/models/medication.dart';
import 'package:app/services/database_service.dart';
import 'package:app/widgets/loading_animation.dart';

class MedReminders extends StatefulWidget {
  const MedReminders({super.key});

  @override
  State<MedReminders> createState() => _MedRemindersState();
}

class _MedRemindersState extends State<MedReminders> {
  List<Medication> _medications = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final meds = await DatabaseService().getAllUserMedications();
    if (mounted) {
      setState(() {
        _medications = meds;
        _isLoading = false;
      });
    }
  }

  int get _totalReminders => _medications.length;
  int get _pendingReminders {
    // Count the actual number of reminder time slots to match the list display
    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    int count = 0;
    for (var med in _medications) {
      if (!med.isCompleted && med.enableReminders) {
        final takenToday = med.takenDoses[dateKey] ?? [];
        // Only count reminder times NOT taken today
        count += med.reminderTimes.where((t) => !takenToday.contains(t)).length;
      }
    }
    return count;
  }

  int get _completedReminders {
    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    int count = 0;
    for (var med in _medications) {
      if (med.isCompleted)
        continue; // If permanently completed, don't count? Or maybe do?
      final takenToday = med.takenDoses[dateKey] ?? [];
      count += takenToday.length;
    }
    return count;
  }

  Future<void> _toggleTakenToday(
    Medication med,
    String time,
    bool isTaken,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await DatabaseService().toggleMedicationTakenToday(med, time, isTaken);
      // Refresh local data
      final updatedMeds = await DatabaseService().getAllUserMedications();
      if (mounted) {
        setState(() {
          _medications = updatedMeds;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating status',
              style: TextStyle(color: Colors.white.themed(context)),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final reminders = _medications
        .where((m) => !m.isCompleted && m.enableReminders)
        .expand((m) => m.reminderTimes.map((t) => MedicationReminder(m, t)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Stack(
        children: [
          Column(
            children: [
              // Header with summary cards
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF277AFF).themedWith(isDark),
                ),
                child: Column(
                  children: [
                    // Top bar
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
                            'Medication Reminders',
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

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            '$_totalReminders',
                            'Total',
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            '$_pendingReminders',
                            'Pending',
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            '$_completedReminders',
                            'Taken Today',
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Reminders List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      reminders.length + 1, // +1 for the info card at the end
                  itemBuilder: (context, index) {
                    if (index == reminders.length) {
                      return _buildManageRemindersCard(isDark);
                    }
                    return _buildReminderCard(reminders[index], index, isDark);
                  },
                ),
              ),
            ],
          ),
          if (_isLoading || _isProcessing)
            Container(
              color: Colors.black.themedWith(isDark).withValues(alpha: 0.3),
              child: const Center(child: LoadingAnimation(size: 150)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.themedWith(isDark).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white.themedWith(isDark),
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.themedWith(isDark),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    MedicationReminder reminder,
    int index,
    bool isDark,
  ) {
    final med = reminder.medication;
    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    final isTakenToday =
        med.takenDoses[dateKey]?.contains(reminder.time) ?? false;
    final isStanceCompleted = med.isCompleted || isTakenToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.themedWith(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStanceCompleted
              ? const Color(0xFF3AC0A0).themedWith(isDark)
              : const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Time icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isStanceCompleted
                        ? const Color(0xFF3AC0A0).themedWith(isDark)
                        : const Color(0xFF277AFF).themedWith(isDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.white.themedWith(isDark),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Medication info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              med.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                          ),
                          if (isStanceCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5F1,
                                ).themedWith(isDark),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                med.isCompleted ? 'Completed' : 'Taken Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        med.dosage,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278).themedWith(isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD).themedWith(isDark),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          med.diagnosisId ?? 'General',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF277AFF).themedWith(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Time and action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      reminder.time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF2B2F33).themedWith(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Details button
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/medDetail',
                              arguments: med,
                            );
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: const Color(0xFF277AFF).themedWith(isDark),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (!med.isCompleted) ...[
                          const SizedBox(width: 12),
                          // Quick complete button icon
                          IconButton(
                            onPressed: () => _toggleTakenToday(
                              med,
                              reminder.time,
                              !isTakenToday,
                            ),
                            icon: Icon(
                              isTakenToday
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: const Color(0xFF3AC0A0).themedWith(isDark),
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (!med.isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () =>
                      _toggleTakenToday(med, reminder.time, !isTakenToday),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTakenToday
                        ? (Colors.grey[400] ?? Colors.grey).themedWith(isDark)
                        : const Color(0xFF3AC0A0).themedWith(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isTakenToday ? 'Mark as Not Taken' : 'Mark as Taken Today',
                    style: TextStyle(
                      color: Colors.white.themedWith(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
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

  Widget _buildManageRemindersCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).themedWith(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
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
                  ).themedWith(isDark).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF277AFF).themedWith(isDark),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Manage Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF277AFF).themedWith(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To add a new reminder, select a medication from the Medications list and enable reminders in the medication details.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: const Color(0xFF2B2F33).themedWith(isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/medsDashboard');
            },
            child: Text(
              'Go to Medications →',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: const Color(0xFF277AFF).themedWith(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationReminder {
  final Medication medication;
  final String time;

  MedicationReminder(this.medication, this.time);
}

import 'package:flutter/material.dart';

class MedReminders extends StatefulWidget {
  const MedReminders({super.key});

  @override
  State<MedReminders> createState() => _MedRemindersState();
}

class _MedRemindersState extends State<MedReminders> {
  final List<ReminderItem> _reminders = [
    ReminderItem(
      medicationName: 'Lisinopril',
      dosage: '10mg',
      time: '8:00 AM',
      diagnosis: 'Hypertension',
      isCompleted: false,
    ),
    ReminderItem(
      medicationName: 'Metformin',
      dosage: '500mg',
      time: '2:00 PM',
      diagnosis: 'Type 2 Diabetes',
      isCompleted: false,
    ),
    ReminderItem(
      medicationName: 'Metformin',
      dosage: '500mg',
      time: '8:00 PM',
      diagnosis: 'Type 2 Diabetes',
      isCompleted: false,
    ),
    ReminderItem(
      medicationName: 'Vitamin D3',
      dosage: '1000 IU',
      time: '9:00 AM',
      diagnosis: 'General',
      isCompleted: true,
    ),
    ReminderItem(
      medicationName: 'Cetirizine',
      dosage: '10mg',
      time: '10:00 PM',
      diagnosis: 'Seasonal Allergies',
      isCompleted: false,
    ),
  ];

  int get _totalReminders => _reminders.length;
  int get _pendingReminders => _reminders.where((r) => !r.isCompleted).length;
  int get _completedReminders => _reminders.where((r) => r.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header with summary cards
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(color: Color(0xFF277AFF)),
            child: Column(
              children: [
                // Top bar
                Row(
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
                    const Expanded(
                      child: Text(
                        'Medication Reminders',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
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
                        Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        '$_pendingReminders',
                        'Pending',
                        Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        '$_completedReminders',
                        'Completed',
                        Colors.white.withOpacity(0.2),
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
                  _reminders.length + 1, // +1 for the info card at the end
              itemBuilder: (context, index) {
                if (index == _reminders.length) {
                  return _buildManageRemindersCard();
                }
                return _buildReminderCard(_reminders[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderItem reminder, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.isCompleted
              ? const Color(0xFF3AC0A0)
              : const Color(0xFFE0E0E0),
          width: reminder.isCompleted ? 2 : 1,
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
                    color: const Color(0xFF277AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
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
                              reminder.medicationName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2B2F33),
                              ),
                            ),
                          ),
                          if (reminder.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5F1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Taken',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF3AC0A0),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.dosage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Color(0xFF6C7278),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reminder.diagnosis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: Color(0xFF277AFF),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF2B2F33),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/medDetail');
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Color(0xFF277AFF),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        // Complete button
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _reminders[index].isCompleted =
                                  !_reminders[index].isCompleted;
                            });
                          },
                          icon: Icon(
                            reminder.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: const Color(0xFF3AC0A0),
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  /*
                  this where we will add the logic to complete the medication
                  the whole reminder related to than medication will be deleted and erasedd from the database
                   */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3AC0A0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Complete Medication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageRemindersCard() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
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
                  color: const Color(0xFF277AFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF277AFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Manage Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF277AFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'To add a new reminder, select a medication from the Medications list and enable reminders in the medication details.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Color(0xFF2B2F33),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/medsDashboard');
            },
            child: const Text(
              'Go to Medications →',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF277AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderItem {
  final String medicationName;
  final String dosage;
  final String time;
  final String diagnosis;
  bool isCompleted;

  ReminderItem({
    required this.medicationName,
    required this.dosage,
    required this.time,
    required this.diagnosis,
    required this.isCompleted,
  });
}

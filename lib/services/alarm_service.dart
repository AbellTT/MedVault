import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';
import '../models/medication.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// Schedules alarms for a medication based on its reminder times.
  /// Each alarm ID is generated from the medication name hash + index.
  Future<void> scheduleMedicationAlarms(Medication med) async {
    if (!med.enableReminders || med.reminderTimes.isEmpty) {
      await cancelMedicationAlarms(med.name);
      return;
    }

    // Cancel existing alarms for this med first
    await cancelMedicationAlarms(med.name);

    final int baseId = med.name.hashCode.abs();

    for (int i = 0; i < med.reminderTimes.length; i++) {
      final timeStr = med.reminderTimes[i];
      // Expecting "HH:mm AM/PM" or "HH:mm"
      final timeParts = timeStr.split(' ');
      final hm = timeParts[0].split(':');
      if (hm.length != 2) continue;

      int hour = int.parse(hm[0]);
      int minute = int.parse(hm[1]);

      if (timeParts.length == 2) {
        final period = timeParts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final alarmId = baseId + i;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: scheduledDate,
        assetAudioPath:
            'assets/audio/alert.mp3', // Replaced with user's specific file
        loopAudio: true,
        vibrate: true,
        volume: 0.5,
        fadeDuration: 3.0,
        warningNotificationOnKill: true,
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: 'Time for ${med.name}',
          body: 'Dosage: ${med.dosage}. Tap to open.',
          stopButton: 'Stop',
          icon: 'notification_icon',
        ),
      );
      debugPrint(
        'ALARM: Scheduling ${med.name} (ID: $alarmId) for $scheduledDate',
      );
      await Alarm.set(alarmSettings: alarmSettings);
    }
  }

  /// Cancels all alarms associated with a medication name.
  Future<void> cancelMedicationAlarms(String medName) async {
    final int baseId = medName.hashCode.abs();
    debugPrint('ALARM: Cancelling alarms for $medName');
    for (int i = 0; i < 10; i++) {
      await Alarm.stop(baseId + i);
    }
  }

}

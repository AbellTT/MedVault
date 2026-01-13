import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/medication.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // 4. Combine Settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 5. Initialize Plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 6. Request Permissions (Android 13+)
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

    // 7. Create Standard Notification Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_reminders',
      'Medication Reminders',
      description: 'Daily medication notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null) return;

    // Payload is medId
    final meds = await DatabaseService().getAllUserMedications();
    Medication? med;
    try {
      med = meds.firstWhere((m) => m.id == payload || m.name == payload);
    } catch (e) {
      return;
    }

    if (response.actionId == 'take') {
      // Find nearest time to mark as taken
      final now = DateTime.now();

      // For notifications, we just mark the first available reminder time for today that isn't taken
      final dateKey = now.toIso8601String().split('T')[0];
      final takenToday = med.takenDoses[dateKey] ?? [];

      String? targetTime;
      for (var time in med.reminderTimes) {
        if (!takenToday.contains(time)) {
          targetTime = time;
          break;
        }
      }

      if (targetTime != null) {
        await DatabaseService().toggleMedicationTakenToday(
          med,
          targetTime,
          true,
        );
      }
      // If triggered from notification action, we should close app?
      // Actually SystemNavigator.pop() only works if app is in foreground.
      // Notification actions usually just dismiss or background-run.
    } else if (response.actionId == 'snooze') {
      // Schedule a one-time snooze in 10 mins
      await scheduleSnooze(med);
    } else if (response.actionId == 'complete') {
      await DatabaseService().completeMedication(med);
    }
  }

  Future<void> scheduleSnooze(Medication med) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 10));
    final id = med.name.hashCode.abs() + 500; // Unique offset for snooze

    await _notifications.zonedSchedule(
      id,
      'Snoozed: ${med.name}',
      'Time to take your ${med.dosage}.',
      scheduledDate,
      _medicationNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: med.id,
    );
  }

  Future<void> scheduleMedicationReminders(Medication med) async {
    if (!med.enableReminders || med.reminderTimes.isEmpty) {
      await cancelMedicationReminders(med.name);
      return;
    }

    // Cancel old reminders first to avoid duplicates
    await cancelMedicationReminders(med.name);

    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    final takenToday = med.takenDoses[dateKey] ?? [];

    for (int i = 0; i < med.reminderTimes.length; i++) {
      final timeStr = med.reminderTimes[i];

      // Check if this specific time slot was already taken today
      bool isTakenToday = false;
      // Handle both "08:00" and "8:00" formats
      for (var takenTime in takenToday) {
        if (takenTime.replaceAll(' ', '') == timeStr.replaceAll(' ', '') ||
            takenTime.replaceAll(' ', '') ==
                timeStr.replaceFirst('0', '').replaceAll(' ', '')) {
          isTakenToday = true;
          break;
        }
      }

      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If it was already taken today, or the time has passed, schedule for tomorrow
      if (isTakenToday || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Generate a unique ID for this specific time
      final baseId = med.name.hashCode;
      final notificationId = baseId.abs() + i;

      debugPrint(
        'SCHEDULING: med=${med.name}, id=$notificationId, time=$scheduledDate, taken=$isTakenToday',
      );

      await _notifications.zonedSchedule(
        notificationId,
        'Time for ${med.name}',
        'Dosage: ${med.dosage}. ${med.instructions}',
        scheduledDate,
        _medicationNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: med.id.isEmpty ? med.name : med.id,
      );
    }
  }

  Future<void> scheduleAppointmentNotification(dynamic appointment) async {
    // appointment is of type Appointment model
    final id = appointment.id.hashCode.abs();
    final now = tz.TZDateTime.now(tz.local);

    // appointment.date is DateTime, appointment.startTime is TimeOfDay
    final DateTime date = appointment.date;
    final dynamic time = appointment.startTime; // TimeOfDay

    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      debugPrint(
        'Notification scheduled time $scheduledDate is in the past. Skipping.',
      );
      return;
    }

    debugPrint('SCHEDULING APPOINTMENT: ID=$id at $scheduledDate');

    await _notifications.zonedSchedule(
      id,
      'Reminder: Appointment with Dr. ${appointment.doctorName}',
      '${appointment.formatTime(null)} at ${appointment.location}',
      scheduledDate,
      _simpleNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'appointment_${appointment.id}',
    );
  }

  Future<void> cancelAllReminders() async {
    debugPrint('CANCELLING ALL notifications');
    await _notifications.cancelAll();
  }

  Future<void> cancelMedicationReminders(String medIdOrName) async {
    final baseId = medIdOrName.hashCode;
    debugPrint('Cancelling notifications for: $medIdOrName (baseId: $baseId)');
    for (int i = 0; i < 10; i++) {
      // Max 10 reminders per med
      await _notifications.cancel(baseId.abs() + i);
    }
  }

  NotificationDetails _medicationNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_reminders',
        'Medication Reminders',
        channelDescription: 'Daily medication notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction('take', 'Take', showsUserInterface: false),
          AndroidNotificationAction(
            'snooze',
            'Snooze',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'complete',
            'Complete',
            showsUserInterface: false,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'med_actions',
      ),
    );
  }

  NotificationDetails _simpleNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_reminders',
        'Medication Reminders',
        channelDescription: 'General notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}

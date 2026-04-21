import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../data/models/reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _remindersChannelId = 'naarya_reminders';
  static const _remindersChannelName = 'Reminders';
  static const _remindersChannelDesc = 'Naarya health reminders';

  static const _fcmChannelId = 'naarya_fcm';
  static const _fcmChannelName = 'Push Notifications';
  static const _fcmChannelDesc = 'Naarya server push notifications';

  // ─── Init ────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTapped,
    );

    // Explicitly create Android channels with max importance so heads-up
    // banners appear both in foreground and background.
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _remindersChannelId,
        _remindersChannelName,
        description: _remindersChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _fcmChannelId,
        _fcmChannelName,
        description: _fcmChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    await _setupFCM();
  }

  // ─── FCM Setup ───────────────────────────────────────────────────────────

  static Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS requires explicit request)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // iOS: show FCM notifications while app is in foreground
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and print FCM token (use this to send targeted notifications)
    final token = await messaging.getToken();
    // ignore: avoid_print
    print('[FCM] Device token: $token');

    // Foreground: show a local notification when FCM arrives while app is open
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap: app was in background and user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Terminated tap: app was closed and opened via notification
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleMessageTap(initial);
    }
  }

  /// Called when FCM message arrives while app is in FOREGROUND
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _fcmChannelId,
          _fcmChannelName,
          channelDescription: _fcmChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Called when user taps an FCM notification (background or terminated)
  static void _handleMessageTap(RemoteMessage message) {
    // Add navigation logic here if needed, e.g.:
    // AppRouter.navigateTo(message.data['route']);
  }

  // ─── Permission ──────────────────────────────────────────────────────────

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ─── Local Notifications ─────────────────────────────────────────────────

  /// Show an immediate notification (foreground use)
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      _reminderNotificationDetails(),
    );
  }

  /// Schedule a notification at a future time (fires even when app is closed)
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    RepeatFrequency repeat = RepeatFrequency.none,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      _reminderNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _repeatComponent(repeat),
    );
  }

  /// Cancel a single scheduled notification
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Breast Exam Reminders ───────────────────────────────────────────────

  // Fixed IDs for breast exam notifications (days 11–14)
  static const _breastExamBaseId = 9011;

  /// Schedule breast self-exam reminders on days 11, 12, 13, 14
  /// after the first day of the period. Fires at 9:00 AM each day.
  /// Call this every time the user updates their period start date.
  static Future<void> scheduleBreastExamReminders(DateTime periodStart) async {
    // Cancel any previously scheduled ones first
    await cancelBreastExamReminders();

    final normalizedStart = DateTime(
      periodStart.year,
      periodStart.month,
      periodStart.day,
    );

    for (int day = 11; day <= 14; day++) {
      final scheduledDate = normalizedStart.add(Duration(days: day - 1));
      final scheduledTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        9, // 9:00 AM
        0,
      );

      // Only schedule if it's in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          _breastExamBaseId + (day - 11), // IDs: 9011, 9012, 9013, 9014
          '🩺 Breast Self-Exam Reminder',
          'Day $day of your cycle — the best time for your monthly breast self-examination.',
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              _remindersChannelId,
              _remindersChannelName,
              channelDescription: _remindersChannelDesc,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  /// Cancel all scheduled breast exam reminders
  static Future<void> cancelBreastExamReminders() async {
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(_breastExamBaseId + i);
    }
  }

  // ─── FCM Token ───────────────────────────────────────────────────────────

  /// Get the FCM device token to use for sending targeted push notifications
  static Future<String?> getFCMToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  static NotificationDetails _reminderNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _remindersChannelId,
        _remindersChannelName,
        channelDescription: _remindersChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  static DateTimeComponents? _repeatComponent(RepeatFrequency repeat) {
    switch (repeat) {
      case RepeatFrequency.daily:
        return DateTimeComponents.time;
      case RepeatFrequency.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatFrequency.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatFrequency.none:
        return null;
    }
  }

  static void _onTapped(NotificationResponse response) {
    // Handle local notification tap — navigate based on response.payload if needed
  }
}

@pragma('vm:entry-point')
void _onBackgroundTapped(NotificationResponse response) {
  // Handle tap when app is in background/terminated
}

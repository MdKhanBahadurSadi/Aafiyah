import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundMessages;
  StreamSubscription<String>? _tokenRefresh;
  String? _activeUid;
  String? _lastToken;

  static const String medicationChannelId = 'medication_reminders_channel';
  static const String medicationChannelName = 'Medication Reminders';

  static const String generalChannelId = 'general_notifications';
  static const String generalChannelName = 'General Notifications';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    await _createChannels();
    try {
      _foregroundMessages ??= FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title;
        final body = message.notification?.body;
        if (title == null || body == null) return;
        unawaited(
          showInstantNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
            title: title,
            body: body,
          ),
        );
      });
      _tokenRefresh ??= FirebaseMessaging.instance.onTokenRefresh.listen((
        token,
      ) {
        final uid = _activeUid;
        if (uid != null) unawaited(_saveDeviceToken(uid, token));
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await registerUserDevice(user.uid);
    } catch (error) {
      // Push delivery is optional until the Firebase project enables Messaging.
      debugPrint('Push messaging is not configured yet: $error');
    }
  }

  Future<void> requestPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      debugPrint('Unable to request push notification permission: $error');
    }
    if (Platform.isAndroid) {
      // Request notification permission (Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Request exact alarm permission (Android 13+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> registerUserDevice(String uid) async {
    _activeUid = uid;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      _lastToken = token;
      await _saveDeviceToken(uid, token);
    } catch (error) {
      debugPrint(
        'Unable to register this device for push notifications: $error',
      );
    }
  }

  Future<void> unregisterUserDevice(String uid) async {
    _activeUid = null;
    try {
      final token = _lastToken ?? await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await FirebaseFirestore.instance
          .collection('userDevices')
          .doc(uid)
          .collection('tokens')
          .doc(_tokenDocumentId(token))
          .delete();
    } catch (error) {
      debugPrint('Unable to remove the signed-out device token: $error');
    }
  }

  Future<void> _saveDeviceToken(String uid, String token) async {
    _lastToken = token;
    await FirebaseFirestore.instance
        .collection('userDevices')
        .doc(uid)
        .collection('tokens')
        .doc(_tokenDocumentId(token))
        .set({
          'token': token,
          'platform': Platform.operatingSystem,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  String _tokenDocumentId(String token) =>
      base64Url.encode(utf8.encode(token)).replaceAll('=', '');

  Future<void> _createChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          medicationChannelId,
          medicationChannelName,
          description: 'Critical alerts for taking your medications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          generalChannelId,
          generalChannelName,
          description: 'General app notifications',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  static void _onNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'snooze' &&
        (details.payload ?? '').startsWith('refill:')) {
      _instance._snoozeRefill(details.payload!.substring('refill:'.length));
      return;
    }
    debugPrint('Notification action: ${details.actionId}');
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'snooze' &&
        (details.payload ?? '').startsWith('refill:')) {
      _instance._snoozeRefill(details.payload!.substring('refill:'.length));
      return;
    }
    debugPrint(
      'Background action: ${details.actionId} for payload: ${details.payload}',
    );
  }

  Future<void> _snoozeRefill(String planId) async {
    final scheduled = DateTime.now().add(const Duration(days: 1));
    try {
      await scheduleMedicationNotification(
        id: _stableNotificationId(planId),
        title: 'Refill reminder: medication supply',
        body: 'Review your prescription and confirm any refill yourself.',
        scheduledTime: scheduled,
        payload: 'refill:$planId',
      );
    } catch (error) {
      debugPrint('Unable to schedule snoozed refill reminder: $error');
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final reference = FirebaseFirestore.instance
            .collection('medicationPlans')
            .doc(planId);
        final snapshot = await reference.get();
        if (snapshot.data()?['patientUid'] == user.uid &&
            snapshot.data()?['active'] == true) {
          await reference.update({
            'remindAt': Timestamp.fromDate(scheduled),
            'snoozedAt': FieldValue.serverTimestamp(),
            'reminderSentAt': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          await reference.collection('reminderHistory').add({
            'type': 'snoozed',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (error) {
      debugPrint('Unable to sync snoozed refill reminder: $error');
    }
  }

  int _stableNotificationId(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return 1000000000 + (hash % 1000000000);
  }

  /// New Method for specific medication scheduling
  Future<void> scheduleMedicationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          medicationChannelId,
          medicationChannelName,
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          ticker: 'Medication Reminder',
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'taken',
              '✅ Taken',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'snooze',
              '⏰ Snooze',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'skip',
              '❌ Skip',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'medication_category',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Compatibility Method for legacy calls
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    return scheduleMedicationNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }

  /// Compatibility Method for instant notifications
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          generalChannelId,
          generalChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

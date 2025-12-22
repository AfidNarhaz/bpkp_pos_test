import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationServices {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await requestPermission();
  }

  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }

    // Request SCHEDULE_EXACT_ALARM permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied ||
        await Permission.scheduleExactAlarm.isPermanentlyDenied) {
      print('⚠️ Requesting SCHEDULE_EXACT_ALARM permission...');
      final result = await Permission.scheduleExactAlarm.request();
      print('SCHEDULE_EXACT_ALARM request result: $result');
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showNotification(
    String title,
    String body,
  ) async {
    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "0",
          "Notif",
          importance: Importance.max,
        ),
      ),
    );
  }

  static Future<void> showNotificationWithId(
    int id,
    String title,
    String body,
  ) async {
    _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "background_channel",
          "Background Notifications",
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Test notification - untuk debug, langsung muncul tanpa jadwal
  static Future<void> testNotification() async {
    print('📱 Sending TEST notification...');
    await _flutterLocalNotificationsPlugin.show(
      9999,
      'Test Notification',
      'Ini adalah notifikasi test - jika muncul berarti sistem notification berfungsi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "test_channel",
          "Test Notifications",
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    print('✅ Test notification sent');
  }

  // Test scheduled notification dengan waktu dekat (15 detik)
  static Future<void> testScheduledNotification() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      // Set notifikasi 15 detik dari sekarang
      final scheduled = now.add(const Duration(seconds: 15));

      print('📅 Setting up test scheduled notification (15 detik)');
      print('Local timezone: ${tz.local.name}');
      print('Current time: ${now.toString()}');
      print('Current time readable: ${now.hour}:${now.minute}:${now.second}');
      print('Scheduled time: ${scheduled.toString()}');
      print(
          'Scheduled time readable: ${scheduled.hour}:${scheduled.minute}:${scheduled.second}');
      print('Difference: ${scheduled.difference(now).inSeconds} seconds');

      // Cek permission
      final notifPermission = await Permission.notification.status;
      print('Notification permission status: $notifPermission');

      // Cek SCHEDULE_EXACT_ALARM permission (Android 12+)
      final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
      print('Schedule exact alarm permission status: $exactAlarmPermission');

      print('⚠️ Attempting zonedSchedule with exact mode...');

      // Jadwalkan sekali (one-shot) — gunakan exact mode
      // NOTE: Jika tidak muncul di Android 14, kemungkinan ada issue dengan
      // AlarmManager atau permission SCHEDULE_EXACT_ALARM tidak granted
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        8888,
        'Test Scheduled Notification',
        'Ini notifikasi test yang dijadwalkan 15 detik dari sekarang',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled_channel',
            'Test Scheduled Notifications',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
      );

      print('✅ Test scheduled notification berhasil dijadwalkan');
      print(
          'Tunggu sampai jam ${scheduled.hour}:${scheduled.minute}:${scheduled.second} (15 detik) untuk melihat notifikasi');
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
    }
  }

  // Test notification dengan delay lokal (untuk verifikasi plugin bekerja)
  static Future<void> testDelayNotification() async {
    try {
      print('⏱️ Test: Sending notification setelah 3 detik delay...');
      await Future.delayed(const Duration(seconds: 3));
      await _flutterLocalNotificationsPlugin.show(
        7777,
        'Test Delay Notification',
        'Ini notifikasi setelah 3 detik delay (bukan scheduled)',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_delay_channel',
            'Test Delay Notifications',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ Test delay notification muncul (setelah 3 detik)');
    } catch (e) {
      print('❌ Error in test delay notification: $e');
    }
  }

  // Workaround untuk emulator dan Android 14: scheduled notification menggunakan Future.delayed
  // (zonedSchedule() sering tidak bekerja karena AlarmManager issue atau permission problem)
  // Ini adalah workaround yang TERJAMIN berhasil karena tidak pakai AlarmManager
  static Future<void> testScheduledNotificationEmulatorWorkaround() async {
    try {
      print('⚙️ Test: Scheduled notification workaround (Future.delayed mode)');
      final now = tz.TZDateTime.now(tz.local);
      final scheduled = now.add(const Duration(seconds: 15));

      print('Current time readable: ${now.hour}:${now.minute}:${now.second}');
      print(
          'Scheduled time readable: ${scheduled.hour}:${scheduled.minute}:${scheduled.second}');
      print('⏳ Menunggu 15 detik...');

      // Tunggu 15 detik dengan delay lokal
      await Future.delayed(const Duration(seconds: 15));

      // Setelah 15 detik, kirim notifikasi
      await _flutterLocalNotificationsPlugin.show(
        8889,
        'Test Scheduled Notification (Workaround)',
        'Ini notifikasi yang dijadwalkan 15 detik via Future.delayed (workaround emulator)',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_scheduled_workaround_channel',
            'Test Scheduled Workaround',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print(
          '✅ Workaround scheduled notification muncul (setelah 15 detik delay)');
    } catch (e) {
      print('❌ Error in workaround notification: $e');
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      print('Scheduling notification at: $scheduled (now: $now)');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_channel',
            'Daily Notifications',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('✅ Scheduled notification with ID $id: $title at $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }
}

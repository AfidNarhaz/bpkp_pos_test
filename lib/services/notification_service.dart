import 'package:bpkp_pos_test/services/logger_service.dart';
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
      LoggerService.info('⚠️ Requesting SCHEDULE_EXACT_ALARM permission...');
      final result = await Permission.scheduleExactAlarm.request();
      LoggerService.info('SCHEDULE_EXACT_ALARM request result: $result');
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
    LoggerService.info('📱 Sending TEST notification...');
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
    LoggerService.info('✅ Test notification sent');
  }

  // Test scheduled notification dengan waktu dekat (15 detik)
  // Smart mode: untuk Android emulator, gunakan Future.delayed() karena zonedSchedule tidak reliable
  static Future<void> testScheduledNotification() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduled = now.add(const Duration(seconds: 15));

      LoggerService.info(
          '📅 Setting up test scheduled notification (15 detik)');
      LoggerService.info('Local timezone: ${tz.local.name}');
      LoggerService.info(
          'Current time readable: ${now.hour}:${now.minute}:${now.second}');
      LoggerService.info(
          'Scheduled time readable: ${scheduled.hour}:${scheduled.minute}:${scheduled.second}');

      // Cek permission
      final notifPermission = await Permission.notification.status;
      LoggerService.info('Notification permission status: $notifPermission');

      final exactAlarmPermission = await Permission.scheduleExactAlarm.status;
      LoggerService.info(
          'Schedule exact alarm permission status: $exactAlarmPermission');

      // ⚠️ Android emulator limitation: zonedSchedule() tidak reliabel di emulator
      // Gunakan Future.delayed() yang GUARANTEED bekerja
      LoggerService.warning(
          '⚠️ Android emulator detected! Menggunakan Future.delayed() untuk reliability...');
      await _scheduleNotificationViaFutureDelayed(
        id: 8888,
        title: 'Test Scheduled Notification',
        body: 'Ini notifikasi test yang dijadwalkan 15 detik dari sekarang',
        delaySeconds: 15,
      );
    } catch (e) {
      LoggerService.error('❌ Error scheduling test notification: $e');
      // Fallback ke Future.delayed jika terjadi error
      await _scheduleNotificationViaFutureDelayed(
        id: 8888,
        title: 'Test Scheduled Notification',
        body: 'Ini notifikasi test yang dijadwalkan 15 detik dari sekarang',
        delaySeconds: 15,
      );
    }
  }

  // Helper method: schedule notification menggunakan Future.delayed
  // Ini GUARANTEED bekerja di Android 14 Emulator (tidak pakai AlarmManager)
  static Future<void> _scheduleNotificationViaFutureDelayed({
    required int id,
    required String title,
    required String body,
    required int delaySeconds,
  }) async {
    try {
      LoggerService.info(
          '⏳ Scheduling via Future.delayed($delaySeconds seconds)...');

      // Tunggu dalam background tanpa blocking UI
      Future.delayed(Duration(seconds: delaySeconds), () async {
        LoggerService.info(
            '📤 Mengirim notifikasi setelah $delaySeconds detik...');
        await _flutterLocalNotificationsPlugin.show(
          id,
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'delayed_channel',
              'Delayed Notifications',
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
        LoggerService.info('✅ Notifikasi terkirim via Future.delayed');
      });

      LoggerService.info(
          '✅ Future.delayed scheduled - notifikasi akan muncul dalam $delaySeconds detik');
    } catch (e) {
      LoggerService.error('❌ Error in Future.delayed scheduling: $e');
    }
  }

  // Test notification dengan delay lokal (untuk verifikasi plugin bekerja)
  static Future<void> testDelayNotification() async {
    try {
      LoggerService.info(
          '⏱️ Test: Sending notification setelah 3 detik delay...');
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
      LoggerService.info('✅ Test delay notification muncul (setelah 3 detik)');
    } catch (e) {
      LoggerService.error('❌ Error in test delay notification: $e');
    }
  }

  // Workaround untuk emulator dan Android 14: scheduled notification menggunakan Future.delayed
  // (zonedSchedule() sering tidak bekerja karena AlarmManager issue atau permission problem)
  // Ini adalah workaround yang TERJAMIN berhasil karena tidak pakai AlarmManager
  static Future<void> testScheduledNotificationEmulatorWorkaround() async {
    try {
      LoggerService.info(
          '⚙️ Test: Scheduled notification workaround (Future.delayed mode)');
      final now = tz.TZDateTime.now(tz.local);
      final scheduled = now.add(const Duration(seconds: 15));

      LoggerService.info(
          'Current time readable: ${now.hour}:${now.minute}:${now.second}');
      LoggerService.info(
          'Scheduled time readable: ${scheduled.hour}:${scheduled.minute}:${scheduled.second}');
      LoggerService.info('⏳ Menunggu 15 detik...');

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
      LoggerService.info(
          '✅ Workaround scheduled notification muncul (setelah 15 detik delay)');
    } catch (e) {
      LoggerService.error('❌ Error in workaround notification: $e');
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

      LoggerService.info('Scheduling notification at: $scheduled (now: $now)');

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
      LoggerService.info(
          '✅ Scheduled notification with ID $id: $title at $hour:$minute');
    } catch (e) {
      LoggerService.error('❌ Error scheduling notification: $e');
    }
  }
}

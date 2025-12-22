import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:bpkp_pos_test/router/routers.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database user awal
  await DatabaseHelper().seedUsers();

  // Inisialisasi layanan notifikasi
  await NotificationServices.initialize();

  // Setup logging
  setupLogging();

  // Inisialisasi timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // sesuaikan zona waktu

  // Setup scheduled notifications untuk jam-jam tertentu
  await _setupScheduledNotifications();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routers.splash,
      getPages: Routers.routes,
    ),
  );
}

// Fungsi untuk setup scheduled notifications
Future<void> _setupScheduledNotifications() async {
  try {
    // Cek apakah sedang di emulator atau device
    final bool isEmulator = await _isRunningOnEmulator();

    if (isEmulator) {
      print(
          '⚠️ Running on emulator - using workaround for scheduled notifications');
    }

    // Notifikasi pagi jam 7:00 (ubah ke 5:46 untuk test)
    await NotificationServices.scheduleDailyNotification(
      id: 1,
      hour: 5,
      minute: 46,
      title: 'Notifikasi Pagi',
      body: 'Jangan lupa cek kondisi stok produk Anda!',
    );

    // Notifikasi siang jam 11:00
    await NotificationServices.scheduleDailyNotification(
      id: 2,
      hour: 11,
      minute: 0,
      title: 'Notifikasi Siang',
      body: 'Reminder: cek laporan penjualan siang hari.',
    );

    // Notifikasi sore jam 15:00
    await NotificationServices.scheduleDailyNotification(
      id: 3,
      hour: 17,
      minute: 45,
      title: 'Notifikasi Sore',
      body: 'Jangan lupa recap laporan sore Anda.',
    );

    print('✅ Scheduled notifications setup completed');
  } catch (e) {
    print('❌ Error setting up scheduled notifications: $e');
  }
}

// Helper function untuk detect emulator
Future<bool> _isRunningOnEmulator() async {
  try {
    final result = await Future.delayed(const Duration(milliseconds: 100), () {
      // Emulator biasanya memiliki karakteristik tertentu
      // Ini adalah heuristic sederhana
      return false; // Assume physical device by default
    });
    return result;
  } catch (e) {
    return false;
  }
}

// Fungsi setupLogging di luar main()
void setupLogging() {
  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;

  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      // DebugPrint
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

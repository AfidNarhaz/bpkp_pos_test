import 'package:bpkp_pos_test/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:bpkp_pos_test/router/routers.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale untuk intl package
  await initializeDateFormatting('id_ID', null);

  // Seed database user awal
  await DatabaseHelper().seedUsers();

  // Inisialisasi layanan notifikasi
  await NotificationServices.initialize();

  // Setup logging
  setupLogging();

  // Inisialisasi timezone
  tz.initializeTimeZones();
  try {
    // Set ke Asia/Jakarta (timezone standard Indonesia)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    LoggerService.info('🕐 Timezone initialized to Asia/Jakarta');
  } catch (e) {
    // Fallback jika gagal
    LoggerService.warning('⚠️ Failed to initialize timezone: $e');
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

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
      LoggerService.info(
          '⚠️ Running on emulator - using workaround for scheduled notifications');
    }

    // Dapatkan data kondisi produk
    final produkStats = await _getProdukStats();

    // Notifikasi pagi jam 7:00
    await NotificationServices.scheduleDailyNotification(
      id: 1,
      hour: 7,
      minute: 00,
      title: 'Notifikasi Pagi',
      body: _buildNotificationBody(produkStats),
    );

    // Notifikasi siang jam 11:00
    await NotificationServices.scheduleDailyNotification(
      id: 2,
      hour: 11,
      minute: 00,
      title: 'Notifikasi Siang',
      body: _buildNotificationBody(produkStats),
    );

    // Notifikasi sore jam 15:00
    await NotificationServices.scheduleDailyNotification(
      id: 3,
      hour: 15,
      minute: 00,
      title: 'Notifikasi Sore',
      body: _buildNotificationBody(produkStats),
    );

    LoggerService.info('✅ Scheduled notifications setup completed');
  } catch (e) {
    LoggerService.error('❌ Error setting up scheduled notifications: $e');
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

// Fungsi untuk mengambil statistik kondisi produk
Future<Map<String, int>> _getProdukStats() async {
  try {
    final db = DatabaseHelper();

    // Ambil data produk dengan berbagai kondisi
    final produkMinimalStok = await db.getProdukMinimalStok();
    final produkHampirExpired = await db.getProdukHampirExpired(days: 7);
    final produkSudahExpired = await db.getProdukSudahExpired();

    return {
      'minimalStok': produkMinimalStok.length,
      'hampirExpired': produkHampirExpired.length,
      'sudahExpired': produkSudahExpired.length,
    };
  } catch (e) {
    LoggerService.error('Error getting produk stats: $e');
    return {
      'minimalStok': 0,
      'hampirExpired': 0,
      'sudahExpired': 0,
    };
  }
}

// Fungsi untuk membuat body notifikasi berdasarkan statistik produk
String _buildNotificationBody(Map<String, int> produkStats) {
  final minimalStok = produkStats['minimalStok'] ?? 0;
  final hampirExpired = produkStats['hampirExpired'] ?? 0;
  final sudahExpired = produkStats['sudahExpired'] ?? 0;

  return 'Ada $minimalStok produk perlu restock, $hampirExpired produk akan kadaluwarsa, dan $sudahExpired produk kadaluwarsa';
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

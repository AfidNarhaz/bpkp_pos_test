import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:workmanager/workmanager.dart';
import 'package:bpkp_pos_test/router/routers.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:bpkp_pos_test/background/background_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database user awal
  await DatabaseHelper().seedUsers();

  // Inisialisasi layanan notifikasi
  await NotificationService.init();

  if (!kDebugMode) {
    // Workmanager hanya di non-debug
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      "1",
      dailyReportTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }

  // Setup logging
  setupLogging();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routers.splash,
      getPages: Routers.routes,
    ),
  );
}

// Fungsi setupLogging di luar main()
void setupLogging() {
  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;

  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      // Gunakan debugPrint agar output panjang tidak terpotong
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

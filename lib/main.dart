import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:bpkp_pos_test/router/routers.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database user awal
  await DatabaseHelper().seedUsers();

  // Inisialisasi layanan notifikasi
  await NotificationServices.initialize();

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
      // DebugPrint
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

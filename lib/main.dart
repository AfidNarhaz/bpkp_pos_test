import 'package:bpkp_pos_test/router/routers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().seedUsers();

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
  if (kReleaseMode) {
    Logger.root.level = Level.WARNING;
  } else {
    Logger.root.level = Level.ALL;
  }

  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

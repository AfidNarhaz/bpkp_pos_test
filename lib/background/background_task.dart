import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/services/logger_service.dart';
import 'package:workmanager/workmanager.dart';

const String dailyReportTask = "dailyReportTask";
const String checkProductConditionTask = "checkProductConditionTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case dailyReportTask:
          // NOTE: Do not call UI / platform notification APIs from the
          // background isolate unless plugins are properly registered for
          // background execution. See comments below for registration steps.
          LoggerService.info(
              'Background task: dailyReportTask (DB-only, no OS notification)');
          break;

        case checkProductConditionTask:
          // Jalankan check kondisi produk (expired, stok minimal, dll)
          final dbHelper = DatabaseHelper();
          await dbHelper.checkAndNotifyProdukConditions();

          // Jalankan DB-only check; tulis notifikasi ke database.
          // DO NOT call notification plugin methods here — on some devices
          // / emulator this background isolate does not have plugin
          // registration and calling platform APIs will crash (NullPointerException).
          final newNotifs = await dbHelper.getNotifikasi();
          LoggerService.info(
              'Background task: checkProductConditionTask completed, found ${newNotifs.length} notifikasi (DB updated)');
          break;
      }

      return Future.value(true);
    } catch (e) {
      LoggerService.info('Error in callbackDispatcher: $e');
      return Future.value(false);
    }
  });
}

// Fungsi untuk initialize background task
Future<void> initializeBackgroundTask() async {
  try {
    // Initialize Workmanager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set ke false saat production
    );

    // Register periodic task untuk check kondisi produk setiap 15 menit (default)
    // await Workmanager().registerPeriodicTask(
    //   checkProductConditionTask,
    //   checkProductConditionTask,
    //   frequency: const Duration(minutes: 15),
    //   initialDelay: const Duration(seconds: 10),
    // );

    // Register daily task
    await Workmanager().registerPeriodicTask(
      dailyReportTask,
      dailyReportTask,
      frequency: const Duration(hours: 24),
    );

    LoggerService.info('Background tasks initialized successfully');
  } catch (e) {
    LoggerService.error('Error initializing background tasks: $e');
  }
}

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';

const String dailyReportTask = "dailyReportTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Task: $task running at ${DateTime.now()}");
    // Pastikan notifikasi diinisialisasi
    await NotificationService.init();

    if (task == dailyReportTask) {
      await NotificationService.showNotification(
        title: "Laporan Harian",
        body: "Jangan lupa cek laporan penjualan harian di aplikasi POS!",
      );
    }

    return Future.value(true);
  });
}

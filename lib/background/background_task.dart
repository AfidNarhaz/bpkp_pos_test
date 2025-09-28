import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

const String dailyReportTask = "dailyReportTask";
const String expiredProdukTask = "expiredProdukTask";

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

    if (task == expiredProdukTask) {
      final dbHelper = DatabaseHelper();
      final expiredProduk = await dbHelper.getProdukHampirExpired();
      if (expiredProduk.isNotEmpty) {
        await NotificationService.showNotification(
          title: "Produk Hampir Kadaluwarsa",
          body:
              "Ada ${expiredProduk.length} produk yang akan kadaluwarsa dalam 7 hari.",
        );
      }
    }

    return Future.value(true);
  });
}

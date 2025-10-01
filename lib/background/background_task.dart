import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';

const String dailyReportTask = "dailyReportTask";
const String expiredProdukTask = "expiredProdukTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationServices.initialize();

    switch (task) {
      case dailyReportTask:
        await NotificationServices.showNotification(
          "Daily Report",
          "Jangan lupa cek laporan harian kamu!",
        );
        break;

      case expiredProdukTask:
        await NotificationServices.showNotification(
          "Produk Expired",
         "Ada produk yang sudah kadaluarsa, segera cek!",
        );
        break;
    }

    return Future.value(true);
  });
}

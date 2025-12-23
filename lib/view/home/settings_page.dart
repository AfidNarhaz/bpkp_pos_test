import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/helper/db_exporter.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings Test',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Button export database
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export Database (POS.db)'),
                  onPressed: () async {
                    try {
                      final path = await DbExporter.exportDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('DB berhasil diexport ke:\n$path')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal export DB: $e')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Button test notifikasi OS HP
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testOSNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text(
                    'Test Notifikasi OS HP',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Button test untuk check kondisi produk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _testCheckProductCondition,
                  icon: _isChecking
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withAlpha(200),
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isChecking ? 'Checking...' : 'Test Check Produk',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Button test scheduled notification
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testScheduledNotification,
                  icon: const Icon(Icons.schedule),
                  label: const Text(
                    'Test Scheduled (15 detik)',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Button test delay notification
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testDelayNotification,
                  icon: const Icon(Icons.timer),
                  label: const Text(
                    'Test Delay (3 detik) - untuk verifikasi',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Button test scheduled notification workaround
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testScheduledNotificationWorkaround,
                  icon: const Icon(Icons.alarm),
                  label: const Text(
                    'Test Scheduled Workaround (15 detik) - Emulator',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.amber),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testOSNotification() async {
    try {
      // Test notifikasi langsung (tidak dijadwalkan)
      await NotificationServices.testNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Test notification telah dikirim! Cek notification bar HP'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _testCheckProductCondition() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Jalankan check kondisi produk
      await DatabaseHelper().checkAndNotifyProdukConditions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check kondisi produk selesai. Cek notifikasi!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _testScheduledNotification() async {
    try {
      // Test notifikasi yang dijadwalkan 15 detik dari sekarang
      await NotificationServices.testScheduledNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Notifikasi dijadwalkan! Tunggu 15 detik dan cek notification bar'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _testDelayNotification() async {
    try {
      // Test notifikasi dengan delay lokal (bukan scheduled)
      // Ini untuk verifikasi bahwa plugin notifikasi bekerja
      await NotificationServices.testDelayNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('⏱️ Notifikasi akan muncul dalam 3 detik (test plugin)'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _testScheduledNotificationWorkaround() async {
    try {
      // Workaround untuk emulator: gunakan Future.delayed + show()
      // daripada zonedSchedule() yang sering gagal di Android 7 emulator
      await NotificationServices.testScheduledNotificationEmulatorWorkaround();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '⚙️ Workaround: Notifikasi akan muncul dalam 15 detik (via Future.delayed)'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

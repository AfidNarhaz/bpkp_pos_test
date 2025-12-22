import 'package:bpkp_pos_test/view/home/bantuan.dart';
import 'package:bpkp_pos_test/view/pembelian/pembelian.dart';
import 'package:bpkp_pos_test/view/produk/kelola_produk_page.dart';
import 'package:bpkp_pos_test/view/penjualan/transaksi_page.dart';
import 'package:bpkp_pos_test/view/home/notification/notification_page.dart';
import 'package:bpkp_pos_test/view/pegawai/pegawai_page.dart';
import 'package:bpkp_pos_test/view/laporan/laporan.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/background/background_task.dart';
import 'package:bpkp_pos_test/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Initialize background task saat app start
    initializeBackgroundTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BantuanPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildIconWithLabel(Icons.inventory_2_outlined, 'Produk'),
                    _buildIconWithLabel(Icons.badge_outlined, 'Pegawai'),
                    _buildIconWithLabel(
                        Icons.point_of_sale_outlined, 'Penjualan'),
                    _buildIconWithLabel(
                        Icons.point_of_sale_outlined, 'Pembelian'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Laporan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LaporanPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Text(
                          "Lihat Semua",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLaporanCard('Penjualan hari ini', ''),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLaporanCard('Penjualan bulan ini', ''),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Button test notifikasi OS (untuk debug)
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
              // Button test untuk check kondisi produk (untuk debug)
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
              // Button test scheduled notification (untuk debug)
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
              // Button test delay notification (verifikasi plugin bekerja)
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
              // Button test scheduled notification workaround (untuk emulator)
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

  Widget _buildIconWithLabel(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Produk') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KelolaProdukPage()),
          );
        }
        if (label == 'Pegawai') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PegawaiPage()),
          );
        }
        if (label == 'Penjualan') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransaksiPage(),
            ),
          );
        }
        if (label == 'Pembelian') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Pembelian(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Yakin ingin logout?'),
          actions: [
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:bpkp_pos_test/view/home/bantuan.dart';
import 'package:bpkp_pos_test/view/pembelian/pembelian.dart';
import 'package:bpkp_pos_test/view/produk/kelola_produk_page.dart';
import 'package:bpkp_pos_test/view/penjualan/transaksi_page.dart';
import 'package:bpkp_pos_test/view/home/notification/notification_page.dart';
import 'package:bpkp_pos_test/view/home/settings_page.dart';
import 'package:bpkp_pos_test/view/pegawai/pegawai_page.dart';
import 'package:bpkp_pos_test/view/laporan/laporan.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/background/background_task.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<double> _totalPenjualanHariIni;
  late Future<double> _totalPenjualanBulanIni;

  @override
  void initState() {
    super.initState();
    // Initialize background task saat app start
    initializeBackgroundTask();
    // Load total penjualan hari ini
    _totalPenjualanHariIni = _getTotalPenjualanHariIni();
    // Load total penjualan bulan ini
    _totalPenjualanBulanIni = _getTotalPenjualanBulanIni();
  }

  Future<double> _getTotalPenjualanHariIni() async {
    try {
      final today = DateTime.now();
      final penjualan = await _dbHelper.getListPenjualan(
        startDate: today,
        endDate: today,
      );

      double total = 0;
      for (var item in penjualan) {
        final amount = (item['total_transaksi'] as num?)?.toDouble() ?? 0;
        total += amount;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getTotalPenjualanBulanIni() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final penjualan = await _dbHelper.getListPenjualan(
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
      );

      double total = 0;
      for (var item in penjualan) {
        final amount = (item['total_transaksi'] as num?)?.toDouble() ?? 0;
        total += amount;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp${formatter.format(value)}';
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
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
                    child: FutureBuilder<double>(
                      future: _totalPenjualanHariIni,
                      builder: (context, snapshot) {
                        String displayValue = '';
                        if (snapshot.connectionState == ConnectionState.done) {
                          displayValue = _formatCurrency(snapshot.data ?? 0);
                        } else if (snapshot.hasError) {
                          displayValue = 'Error';
                        }
                        return _buildLaporanCard(
                            'Penjualan hari ini', displayValue);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FutureBuilder<double>(
                      future: _totalPenjualanBulanIni,
                      builder: (context, snapshot) {
                        String displayValue = '';
                        if (snapshot.connectionState == ConnectionState.done) {
                          displayValue = _formatCurrency(snapshot.data ?? 0);
                        } else if (snapshot.hasError) {
                          displayValue = 'Error';
                        }
                        return _buildLaporanCard(
                            'Penjualan bulan ini', displayValue);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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

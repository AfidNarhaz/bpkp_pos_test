import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/home/notification_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/kelola_produk_page.dart';
import 'package:bpkp_pos_test/view/pegawai/pegawai_page.dart';
import 'package:bpkp_pos_test/view/transaksi/transaksi_page.dart';
import 'package:bpkp_pos_test/view/laporan/laporan.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              _showLogoutConfirmation(context); // Menampilkan peringatan logout
            },
          ),
        ],
      ),
      body: Padding(
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
                      Icons.point_of_sale_outlined, 'Transaksi'),
                  _buildIconWithLabel(Icons.help_center_outlined, 'Bantuan'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Laporan section
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
          ],
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
        if (label == 'Transaksi') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransaksiPage()),
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

  // Method untuk membuat card laporan
  Widget _buildLaporanCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // 20% opacity
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
                  Navigator.of(context).pop(); // Tutup dialog
                }
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.pushReplacementNamed(
                      context, '/login'); // Kembali ke halaman login
                }
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:bpkp_pos_test/view/kelola_produk_page.dart';
import 'package:bpkp_pos_test/view/pegawai_page.dart';
import 'package:bpkp_pos_test/view/transaksi_page.dart';
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
      backgroundColor: const Color.fromARGB(255, 186, 227, 236),
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          )
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
                  _buildIconWithLabel(Icons.store, 'Kelola Produk'),
                  _buildIconWithLabel(Icons.people, 'Pegawai'),
                  _buildIconWithLabel(Icons.receipt, 'Transaksi'),
                  _buildIconWithLabel(Icons.help, 'Bantuan'),
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
                    // aksi untuk tombol "lihat semua"
                  },
                  child: const Row(
                    children: [
                      Text("Lihat Semua", style: TextStyle(fontSize: 16)),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithLabel(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Kelola Produk') {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
}

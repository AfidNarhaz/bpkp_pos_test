import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/laporan/laporan.dart';
import 'package:bpkp_pos_test/view/laporan/ringkasan_penjualan.dart';

class LaporanDrawer extends StatelessWidget {
  final BuildContext parentContext;
  const LaporanDrawer({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.cyan,
            ),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Laporan',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Laporan'),
            onTap: () {
              Navigator.pushReplacement(
                parentContext,
                MaterialPageRoute(builder: (context) => const LaporanPage()),
              );
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.description),
            title: const Text('Laporan'),
            children: [
              ListTile(
                title: const Text('Ringkasan Penjualan'),
                onTap: () {
                  Navigator.pushReplacement(
                    parentContext,
                    MaterialPageRoute(
                        builder: (context) => const RingkasanPenjualanPage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Metode Pembayaran'),
                onTap: () {
                  // TODO: Navigasi ke halaman Metode Pembayaran
                  Navigator.pop(parentContext);
                },
              ),
              ListTile(
                title: const Text('Penjualan Per Kategori'),
                onTap: () {
                  // TODO: Navigasi ke halaman Penjualan Per Kategori
                  Navigator.pop(parentContext);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

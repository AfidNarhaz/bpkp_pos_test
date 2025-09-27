import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_state.dart';
import 'package:bpkp_pos_test/view/laporan/ringkasan_penjualan.dart';
import 'package:bpkp_pos_test/view/laporan/riwayat_pembelian.dart';
import 'package:bpkp_pos_test/view/laporan/riwayat_penjualan/riwayat_penjualan.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/laporan/laporan.dart';
// import 'package:bpkp_pos_test/view/laporan/ringkasan_penjualan.dart';
// import 'package:bpkp_pos_test/view/laporan/date_range_state.dart';

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
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Ringkasan Penjualan'),
            onTap: () {
              Navigator.pushReplacement(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RingkasanPenjualanPage(
                    startDate: GlobalDateRange.startDate,
                    endDate: GlobalDateRange.endDate,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Penjualan'),
            onTap: () {
              Navigator.pushReplacement(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => RiwayatPenjualanPage(
                    startDate: GlobalDateRange.startDate,
                    endDate: GlobalDateRange.endDate,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Riwayat Pembelian'),
            onTap: () {
              Navigator.pushReplacement(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const KatalogProduk(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

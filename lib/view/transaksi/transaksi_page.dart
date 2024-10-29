import 'package:bpkp_pos_test/view/transaksi/tab_manual/tab_manual.dart';
import 'package:flutter/material.dart';

// package:bpkp_pos_test/view/kelola_produk_page.dart

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manual'),
              Tab(text: 'Produk'),
              Tab(text: 'Favorite'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ManualTab(), // Panggil widget ManualTab yang telah dibuat
            _buildStokTab(),
            _buildPenjualanTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStokTab() {
    return const Center(
      child: Text(
        'Produk',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildPenjualanTab() {
    return const Center(
      child: Text(
        'Favorite',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

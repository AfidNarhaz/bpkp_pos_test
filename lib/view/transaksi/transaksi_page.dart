import 'package:bpkp_pos_test/view/transaksi/tab_favorite.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_manual.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_produk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bpkp_pos_test/helper/min_child_size.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  final int initialTabIndex;
  const TransaksiPage({super.key, this.initialTabIndex = 0});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tambahkan state keranjang
  List<Map<String, dynamic>> keranjang = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String displayText = 'Rp0';
  double total = 0;
  final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 2.0,
              color: AppColors.text,
            ),
          ),
          labelColor: AppColors.text,
          unselectedLabelColor: AppColors.hidden,
          tabs: const [
            Tab(text: 'Manual'),
            Tab(text: 'Produk'),
            Tab(text: 'Favorite'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              const ManualTab(),
              ProdukTab(onAddToCart: tambahKeKeranjang), // <-- oper fungsi
              FavoriteTab(onAddToCart: tambahKeKeranjang), // <-- oper fungsi
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.17,
            minChildSize: minChildSize,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return DraggableSheetContent(
                scrollController: scrollController,
                keranjang: keranjang, // <-- oper keranjang
                onToggle: () {},
              );
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menambah produk ke keranjang
  void tambahKeKeranjang(Map<String, dynamic> produk) {
    setState(() {
      // Cari produk di keranjang berdasarkan id/barcode
      final index = keranjang.indexWhere((item) => item['id'] == produk['id']);
      if (index != -1) {
        // Jika sudah ada, tambah qty dan update total
        keranjang[index]['qty'] = (keranjang[index]['qty'] ?? 1) + 1;
        keranjang[index]['total'] =
            keranjang[index]['qty'] * (keranjang[index]['hargaJual'] ?? 0);
      } else {
        // Jika belum ada, tambahkan dengan qty = 1
        keranjang.add({
          ...produk,
          'qty': 1,
          'total': produk['hargaJual'] ?? 0,
        });
      }
    });
  }
}

class KeyButton extends StatelessWidget {
  final String text;
  const KeyButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

class DraggableSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onToggle;
  final List<Map<String, dynamic>> keranjang;

  const DraggableSheetContent({
    required this.scrollController,
    required this.onToggle,
    required this.keranjang,
    super.key,
  });

  String _formatCurrency(double? amount) {
    if (amount == null) return '0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Icon(Icons.drag_handle),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = keranjang[index];
                      return ListTile(
                        title: Text(item['nama']),
                        subtitle: Text(
                          '${_formatCurrency(item['hargaJual'])} x ${item['qty']}',
                        ),
                        trailing: Text(
                          _formatCurrency(item['total']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Tambahkan aksi hapus jika perlu
                      );
                    },
                    childCount: keranjang.length,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.cyan),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () {},
            child: Text('Tagih = Rp0'),
          ),
        ],
      ),
    );
  }
}

class FavoriteTabContent extends StatelessWidget {
  const FavoriteTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Favorite',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

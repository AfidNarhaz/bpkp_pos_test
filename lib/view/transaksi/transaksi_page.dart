import 'package:bpkp_pos_test/view/transaksi/tab_favorite.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_manual.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_produk.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  void addToCart(Map<String, dynamic> produk) {
    setState(() {
      cartItems.add(produk);
    });
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
    final peekHeight = MediaQuery.of(context).size.height * 0.1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            borderSide: BorderSide(width: 2.0, color: AppColors.text),
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

      // Bagian utama layar
      body: Padding(
        padding: EdgeInsets.only(bottom: peekHeight), // agar tidak ketimpa
        child: TabBarView(
          controller: _tabController,
          children: [
            const ManualTab(),
            ProdukTab(onProdukTap: addToCart),
            FavoriteTab(onProdukTap: addToCart),
          ],
        ),
      ),

      // Sheet di bagian bawah
      bottomSheet: DraggableScrollableSheet(
        initialChildSize: 0.1,
        minChildSize: 0.1,
        maxChildSize: 0.6,
        expand: false, // WAJIB supaya tidak menutupi penuh
        builder: (ctx, scrollController) {
          return DraggableSheetContent(
            scrollController: scrollController,
            onToggle: () {},
            cartItems: cartItems,
          );
        },
      ),
    );
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
  final List<Map<String, dynamic>> cartItems;

  const DraggableSheetContent({
    required this.scrollController,
    required this.onToggle,
    required this.cartItems,
    super.key,
  });

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
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < 0) {
                onToggle();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.drag_handle),
            ),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('Keranjang kosong'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final produk = cartItems[index];
                      return ListTile(
                        title: Text(produk['nama'] ?? 'Produk'),
                        subtitle: Text('Rp${produk['hargaJual'] ?? ''}'),
                      );
                    },
                  ),
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

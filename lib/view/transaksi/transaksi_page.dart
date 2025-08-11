import 'dart:convert';
import 'package:bpkp_pos_test/view/transaksi/detail_keranjang.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_favorite.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_manual.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_produk.dart';
import 'package:bpkp_pos_test/view/transaksi/pembayaran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bpkp_pos_test/helper/min_child_size.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  final bool showBackButton;
  // ignore: use_super_parameters
  const TransaksiPage({Key? key, this.showBackButton = true}) : super(key: key);

  @override
  State<TransaksiPage> createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> keranjang = [];
  String namaKasir = 'Kasir';
  String username = ''; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _loadKeranjang(); // Muat keranjang dari SharedPreferences
    _loadNamaKasir();
    _loadUsername();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String displayText = 'Rp0';
  double total = 0;
  final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

  Future<void> _saveKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('keranjang', jsonEncode(keranjang));
  }

  Future<void> _loadKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    final keranjangString = prefs.getString('keranjang');
    if (keranjangString != null) {
      setState(() {
        keranjang =
            List<Map<String, dynamic>>.from(jsonDecode(keranjangString));
      });
    }
  }

  Future<void> resetKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('keranjang'); // Hapus keranjang dari SharedPreferences
    setState(() {
      keranjang.clear();
    });
  }

  Future<void> _loadNamaKasir() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Kasir';
    setState(() {
      namaKasir = 'Kasir ${username[0].toUpperCase()}${username.substring(1)}';
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!widget.showBackButton)
            IconButton(
              icon: const Icon(Icons.logout),
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
                keranjang: keranjang,
                onToggle: () {},
                onUpdateKeranjang: (index, updatedProduk) async {
                  // Pastikan fungsi ini async agar bisa menunggu _saveKeranjang
                  onUpdateKeranjang(index, updatedProduk);
                },
                namaKasir: namaKasir, // Tambahkan ini
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
        final hargaSatuan =
            keranjang[index]['hargaNego'] ?? keranjang[index]['hargaJual'] ?? 0;
        keranjang[index]['total'] = keranjang[index]['qty'] * hargaSatuan;
      } else {
        // Jika belum ada, tambahkan dengan qty = 1
        keranjang.add({
          ...produk,
          'qty': 1,
          'total': produk['hargaJual'] ?? 0,
        });
      }
      _saveKeranjang(); // Simpan keranjang setelah diubah
    });
  }

  // Update/hapus produk di keranjang
  void onUpdateKeranjang(int index, Map<String, dynamic>? updatedProduk) async {
    setState(() {
      if (updatedProduk == null) {
        keranjang.removeAt(index);
      } else {
        keranjang[index] = updatedProduk;
      }
    });
    await _saveKeranjang(); // Pastikan selalu simpan perubahan
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
  final Function(int, Map<String, dynamic>?) onUpdateKeranjang;
  final String namaKasir; // Tambahkan ini

  const DraggableSheetContent({
    required this.scrollController,
    required this.onToggle,
    required this.keranjang,
    required this.onUpdateKeranjang,
    required this.namaKasir, // Tambahkan ini
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
                // Tambahan: Row info produk, diskon, pelanggan
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          // Ganti keranjang.length dengan penjumlahan qty
                          '${keranjang.fold<int>(0, (sum, item) => sum + ((item['qty'] ?? 1) as int))} Produk',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.discount, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.people, color: Colors.green),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = keranjang[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(item['nama']),
                            subtitle: Text(
                              '${_formatCurrency(((item['hargaNego'] ?? item['hargaJual']) as num?)?.toDouble())} x ${item['qty']}',
                            ),
                            trailing: Text(
                              _formatCurrency(
                                  (item['total'] as num?)?.toDouble()),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailKeranjangPage(
                                    produk: item,
                                  ),
                                ),
                              );
                              if (result != null) {
                                if (result is Map &&
                                    result['deleted'] == true) {
                                  onUpdateKeranjang(index,
                                      null); // Hapus produk dari keranjang
                                } else {
                                  onUpdateKeranjang(
                                      index, result); // Update produk
                                }
                              }
                            },
                          ),
                          if (index < keranjang.length - 1)
                            const Divider(
                              color: Colors.grey, // warna abu-abu
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
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
            onPressed: () async {
              final totalTagihan = keranjang.fold<num>(
                0,
                (sum, item) => sum + ((item['total'] ?? 0) as num),
              );

              // Navigasi ke halaman pembayaran
              // ignore: unused_local_variable
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PembayaranPage(
                    keranjang: List<Map<String, dynamic>>.from(keranjang),
                    totalTagihan: totalTagihan,
                    namaKasir: namaKasir,
                  ),
                ),
              );

              // Jika pembayaran sukses, bisa lakukan sesuatu di sini (opsional)
            },
            child: Text(
              'Tagih = ${_formatCurrency(keranjang.fold<double>(0, (sum, item) => sum + ((item['total'] ?? 0) as num).toDouble()))}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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

import 'dart:convert';
import 'dart:io';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/penjualan/detail_keranjang.dart';
import 'package:bpkp_pos_test/view/penjualan/pembayaran.dart';
import 'package:bpkp_pos_test/view/produk/widget/barcode_scanner.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bpkp_pos_test/helper/min_child_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  final bool showBackButton;
  const TransaksiPage({super.key, this.showBackButton = true});

  @override
  State<TransaksiPage> createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  List<Map<String, dynamic>> keranjang = [];
  String namaKasir = 'Kasir';
  String username = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadKeranjang();
    _loadNamaKasir();
    _loadUsername();
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
    await prefs.remove('keranjang');
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

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  void _onBarcodeScan() async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (barcode != null && barcode is String) {
      final produkList = await DatabaseHelper().getProduks();
      final produk = produkList.firstWhere(
        (p) => p.barcode == barcode,
        // orElse: () => null,
      );
      tambahKeKeranjang({
        'id': produk.id,
        'nama': produk.nama,
        'hargaJual': produk.hargaJual,
        'barcode': produk.barcode,
        // tambahkan field lain jika perlu
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${produk.nama}" ditambahkan ke keranjang'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama produk...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _onBarcodeScan,
          ),
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
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Tambah padding bawah
            child: ProdukTab(
              onAddToCart: tambahKeKeranjang,
              searchQuery: searchQuery,
            ),
          ),
          SafeArea(
            child: DraggableScrollableSheet(
              initialChildSize: 0.17,
              minChildSize: minChildSize,
              maxChildSize: 1,
              builder: (context, scrollController) {
                return DraggableSheetContent(
                  scrollController: scrollController,
                  keranjang: keranjang,
                  onToggle: () {},
                  onUpdateKeranjang: (index, updatedProduk) async {
                    onUpdateKeranjang(index, updatedProduk);
                  },
                  namaKasir: namaKasir,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void tambahKeKeranjang(Map<String, dynamic> produk) {
    setState(() {
      final index = keranjang.indexWhere((item) => item['id'] == produk['id']);
      if (index != -1) {
        keranjang[index]['qty'] = (keranjang[index]['qty'] ?? 1) + 1;
        final hargaSatuan =
            keranjang[index]['hargaNego'] ?? keranjang[index]['hargaJual'] ?? 0;
        keranjang[index]['total'] = keranjang[index]['qty'] * hargaSatuan;
      } else {
        keranjang.add({
          ...produk,
          'qty': 1,
          'total': produk['hargaJual'] ?? 0,
        });
      }
      _saveKeranjang();
    });
  }

  void onUpdateKeranjang(int index, Map<String, dynamic>? updatedProduk) async {
    setState(() {
      if (updatedProduk == null) {
        keranjang.removeAt(index);
      } else {
        keranjang[index] = updatedProduk;
      }
    });
    await _saveKeranjang();
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
  final String namaKasir;

  const DraggableSheetContent({
    required this.scrollController,
    required this.onToggle,
    required this.keranjang,
    required this.onUpdateKeranjang,
    required this.namaKasir,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
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

class ProdukTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  final String searchQuery;

  const ProdukTab({
    required this.onAddToCart,
    required this.searchQuery,
    super.key,
  });

  @override
  State<ProdukTab> createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Produk> produkList = [];

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    final list = await DatabaseHelper().getProduks();
    setState(() {
      produkList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProduk = produkList
        .where((produk) => produk.nama
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();

    if (filteredProduk.isEmpty) {
      return const Center(child: Text('Tidak ada produk ditemukan'));
    }

    return ListView.builder(
      itemCount: filteredProduk.length,
      itemBuilder: (context, index) {
        final produk = filteredProduk[index];
        return ListTile(
          leading: produk.imagePath != null
              ? Image.file(File(produk.imagePath!),
                  width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.image, size: 50),
          title:
              Text(produk.nama, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('Rp${produk.hargaJual.toStringAsFixed(0)}'),
          trailing: Text('Stok: ${produk.stok ?? 0}'),
          onTap: () {
            widget.onAddToCart({
              'id': produk.id,
              'nama': produk.nama,
              'hargaJual': produk.hargaJual,
              'barcode': produk.barcode,
              // tambahkan field lain jika perlu
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Produk "${produk.nama}" ditambahkan ke keranjang')),
            );
          },
        );
      },
    );
  }
}

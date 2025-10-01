import 'dart:io';
import 'package:bpkp_pos_test/view/laporan/riwayat_produk/detail_riwayat_produk.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_history_produk.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/drawer.dart'; // Tambahkan import drawer

class KatalogProduk extends StatefulWidget {
  const KatalogProduk({super.key});

  @override
  State<KatalogProduk> createState() => _KatalogProdukState();
}

class _KatalogProdukState extends State<KatalogProduk> {
  List<HistoryProduk> historyList = [];
  List<Produk> produkList = [];
  List<Produk> filteredProdukList = [];
  final TextEditingController _searchController = TextEditingController();

  int get totalProduk => produkList.length;
  int get totalStok => produkList.fold(0, (sum, p) => sum + (p.stok ?? 0));
  double get nilaiModal =>
      produkList.fold(0, (sum, p) => sum + (p.hargaBeli * (p.stok ?? 0)));

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadProduk();
    _searchController.addListener(_filterProduk);
  }

  Future<void> _loadHistory() async {
    final list = await DatabaseHelper().getAllHistoryProduk();
    setState(() {
      historyList = list;
    });
  }

  Future<void> _loadProduk() async {
    final list = await DatabaseHelper().getProduks();
    setState(() {
      produkList = list;
      filteredProdukList = list;
    });
  }

  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((p) => p.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showFilterDialog() {
    // TODO: Implementasi filter produk (misal berdasarkan kategori/merek)
  }

  String formatRupiah(num number) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: LaporanDrawer(parentContext: context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Searchbar + Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Produk',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List Produk
            Expanded(
              child: filteredProdukList.isEmpty
                  ? const Center(child: Text('Tidak ada produk ditemukan'))
                  : ListView.separated(
                      itemCount: filteredProdukList.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final produk = filteredProdukList[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
                          leading: produk.imagePath != null &&
                                  produk.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(produk.imagePath!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                          title: Text(produk.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${formatRupiah(produk.hargaJual)}\n${produk.stok ?? 0} Stok',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RiwayatProdukPage(namaProduk: produk.nama),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

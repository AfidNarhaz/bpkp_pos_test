import 'package:bpkp_pos_test/view/kelola_produk/barcode_scanner_page.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class StokTab extends StatefulWidget {
  const StokTab({super.key});

  @override
  StokTabState createState() => StokTabState();
}

class StokTabState extends State<StokTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Produk...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final barcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerPage(),
                      ),
                    );
                    if (!mounted) return;
                    if (barcode != null) {
                      // Cari produk berdasarkan barcode
                      final produkList = await DatabaseHelper().getProduks();
                      if (!mounted) return;
                      final produk = produkList.firstWhereOrNull(
                        (p) => p.barcode == barcode,
                      );
                      if (produk != null) {
                        final stokBaru = await showDialog<int>(
                          context: context,
                          builder: (dialogContext) {
                            final TextEditingController stokController =
                                TextEditingController(
                                    text: produk.stok?.toString() ?? '0');
                            return AlertDialog(
                              title: Text('Atur Stok: \'${produk.nama}\''),
                              content: TextField(
                                controller: stokController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Jumlah Stok Baru'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    if (!dialogContext.mounted) return;
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final value =
                                        int.tryParse(stokController.text);
                                    if (!dialogContext.mounted) return;
                                    Navigator.pop(dialogContext, value);
                                  },
                                  child: const Text('Simpan'),
                                ),
                              ],
                            );
                          },
                        );
                        if (!mounted) return;
                        if (stokBaru != null) {
                          produk.stok = stokBaru;
                          await DatabaseHelper().updateProduk(produk);
                          if (!mounted) return;
                          setState(() {});
                        }
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Produk dengan barcode ini tidak ditemukan.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Produk>>(
              future: DatabaseHelper().getProduks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat stok'));
                }
                final produkList = snapshot.data ?? [];
                final filteredStocks = produkList
                    .where((produk) => produk.nama
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
                if (filteredStocks.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada stok ditemukan',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredStocks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: filteredStocks[index].imagePath != null
                              ? DecorationImage(
                                  image: FileImage(
                                      File(filteredStocks[index].imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.blue[100],
                        ),
                      ),
                      title: Text(filteredStocks[index].nama),
                      subtitle: Text(
                        'Stok: ${filteredStocks[index].stok ?? 0}, '
                        'Min Stok: ${filteredStocks[index].minStok ?? 0}, '
                        'Satuan: ${filteredStocks[index].satuan ?? ''}',
                      ),
                      onTap: () async {
                        // contoh async gap
                        await Future.delayed(Duration.zero);
                        if (!context.mounted) return;
                        // Tambahkan aksi yang menggunakan context di sini
                      },
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // Cancel changes
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      foregroundColor: AppColors.text,
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // Save changes
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

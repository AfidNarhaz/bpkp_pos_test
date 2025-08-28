import 'package:bpkp_pos_test/view/kelola_produk/barcode_scanner.dart';
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              filteredStocks[index].nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${filteredStocks[index].stok ?? 0}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'Min stok: ${filteredStocks[index].minStok ?? 0}, '
                        'Satuan: ${filteredStocks[index].satuan ?? ''}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () async {
                        final produk = filteredStocks[index];
                        int stokBaru = produk.stok ?? 0;
                        String stokMode = 'Stok Disesuaikan';

                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                // Label dinamis
                                String labelJumlah;
                                String rumusStok;
                                if (stokMode == 'Stok Disesuaikan') {
                                  labelJumlah = 'Stok saat ini';
                                  rumusStok = '$stokBaru';
                                } else if (stokMode == 'Stok Ditambahkan') {
                                  labelJumlah = 'Jumlah Stok Ditambahkan';
                                  rumusStok =
                                      '${produk.stok ?? 0} + $stokBaru = ${produk.stok! + stokBaru}';
                                } else {
                                  labelJumlah = 'Jumlah Stok Dikurangkan';
                                  rumusStok =
                                      '${produk.stok ?? 0} - $stokBaru = ${produk.stok! - stokBaru}';
                                }

                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  contentPadding: const EdgeInsets.all(24),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produk.nama,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        produk.barcode,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        initialValue: stokMode,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Stok Disesuaikan',
                                            child: Text('Stok Disesuaikan'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Stok Ditambahkan',
                                            child: Text('Stok Ditambahkan'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Stok Dikurangkan',
                                            child: Text('Stok Dikurangkan'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          setStateDialog(() {
                                            stokMode = val!;
                                            // Reset stokBaru sesuai mode
                                            if (stokMode ==
                                                'Stok Disesuaikan') {
                                              stokBaru = produk.stok ?? 0;
                                            } else {
                                              stokBaru = 0;
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        labelJumlah,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              setStateDialog(() {
                                                if (stokMode ==
                                                    'Stok Disesuaikan') {
                                                  if (stokBaru > 0) stokBaru--;
                                                } else {
                                                  if (stokBaru > 0) stokBaru--;
                                                }
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '$stokBaru',
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setStateDialog(() {
                                                stokBaru++;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        stokMode == 'Stok Disesuaikan'
                                            ? 'Stok Sebelumnya'
                                            : 'Stok saat ini',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      Text(
                                        stokMode == 'Stok Disesuaikan'
                                            ? '${produk.stok ?? 0}'
                                            : rumusStok,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: (stokMode ==
                                                          'Stok Disesuaikan'
                                                      ? stokBaru != produk.stok
                                                      : stokBaru > 0)
                                                  ? () async {
                                                      if (stokMode ==
                                                          'Stok Disesuaikan') {
                                                        produk.stok = stokBaru;
                                                      } else if (stokMode ==
                                                          'Stok Ditambahkan') {
                                                        produk.stok =
                                                            produk.stok! +
                                                                stokBaru;
                                                      } else {
                                                        produk.stok =
                                                            produk.stok! -
                                                                stokBaru;
                                                      }
                                                      await DatabaseHelper()
                                                          .updateProduk(produk);
                                                      Navigator.pop(context);
                                                      setState(
                                                          () {}); // refresh tampilan
                                                    }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                              ),
                                              child: const Text('Simpan',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
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

import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bpkp_pos_test/model/model_produk.dart';

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

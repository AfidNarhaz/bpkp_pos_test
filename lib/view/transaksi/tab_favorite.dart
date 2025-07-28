import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  late Future<List<Produk>> _favoriteProduk;

  @override
  void initState() {
    super.initState();
    _favoriteProduk = _fetchFavoriteProduk();
  }

  Future<List<Produk>> _fetchFavoriteProduk() async {
    final db = DatabaseHelper();
    final allProduk = await db.getProduk();
    return allProduk.where((p) => p.isFavorite).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produk>>(
      future: _favoriteProduk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final produkList = snapshot.data ?? [];
        if (produkList.isEmpty) {
          return const Center(child: Text('Tidak ada produk favorite.'));
        }
        return ListView.builder(
          itemCount: produkList.length,
          itemBuilder: (context, index) {
            final produk = produkList[index];
            final formattedHarga =
                produk.hargaJual.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]}.',
                    );
            return ListTile(
              leading: (produk.imagePath != null &&
                      File(produk.imagePath!).existsSync())
                  ? Image.file(File(produk.imagePath!))
                  : const Icon(Icons.image),
              title: Text(produk.nama),
              subtitle: Text('Rp $formattedHarga'),
              trailing: const Icon(Icons.favorite, color: Colors.yellow),
            );
          },
        );
      },
    );
  }
}

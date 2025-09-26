import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/detail_produk.dart';

class ListTileProduk extends StatelessWidget {
  final Produk produk;
  final VoidCallback? onUpdated;

  const ListTileProduk({
    super.key,
    required this.produk,
    this.onUpdated,
  });

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: produk.imagePath != null
              ? DecorationImage(
                  image: FileImage(File(produk.imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.blue[100],
        ),
      ),
      title: Text(
        produk.nama,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Rp${_formatCurrency(produk.hargaJual)}',
        style: const TextStyle(color: Colors.black54),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Stok',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            produk.stok?.toString() ?? '0',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
      onTap: () async {
        final updatedProduk = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukPage(produk: produk),
          ),
        );
        if (updatedProduk != null && onUpdated != null) {
          onUpdated!();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'tambah_produk_page.dart';

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key}); // Tambahkan parameter key

  @override
  KelolaProdukPageState createState() => KelolaProdukPageState();
}

class KelolaProdukPageState extends State<KelolaProdukPage> {
  List<Product> _produkList = [];

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    List<Product> produkList = await DatabaseHelper().getProduk();
    setState(() {
      _produkList = produkList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Produk'),
      ),
      body: ListView.builder(
        itemCount: _produkList.length,
        itemBuilder: (context, index) {
          final produk = _produkList[index];
          return ListTile(
            title: Text(produk.nama),
            subtitle: Text(produk.merek),
            onTap: () {
              // Navigasi ke halaman detail produk
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahProdukPage()),
          );
          if (newProduct != null) {
            setState(() {
              _produkList.add(newProduct); // Tambahkan produk baru ke daftar
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

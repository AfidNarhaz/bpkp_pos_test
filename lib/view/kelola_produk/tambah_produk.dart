import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/kelola_stok.dart';
import 'package:bpkp_pos_test/database_helper.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  TambahProdukPageState createState() => TambahProdukPageState();
}

class TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController hargaProdukController = TextEditingController();
  Map<String, dynamic>? stokData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: namaProdukController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: hargaProdukController,
              decoration: const InputDecoration(
                labelText: 'Harga Produk',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KelolaStokPage(productId: 1),
                  ),
                );
                if (!mounted) return; // Ensure the state is still mounted
                if (result != null) {
                  setState(() {
                    stokData = result;
                  });
                }
              },
              child: const Text('Kelola Stok'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (namaProdukController.text.isNotEmpty &&
                    hargaProdukController.text.isNotEmpty &&
                    stokData != null) {
                  await DatabaseHelper.instance.addProduct({
                    'namaProduk': namaProdukController.text,
                    'hargaProduk': hargaProdukController.text,
                    'stokProduk': stokData!['stokProduk'],
                    'minimumStock': stokData!['minimumStock'],
                    'isChecked': stokData!['isChecked'],
                  });
                  if (!mounted) return; // Ensure the state is still mounted
                  Navigator.pop;
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

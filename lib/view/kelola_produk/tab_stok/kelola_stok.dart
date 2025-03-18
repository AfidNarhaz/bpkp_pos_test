import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

class KelolaStokPage extends StatefulWidget {
  final int productId; // Add productId parameter

  const KelolaStokPage({super.key, required this.productId});

  @override
  KelolaStokPageState createState() => KelolaStokPageState();
}

class KelolaStokPageState extends State<KelolaStokPage> {
  bool _isChecked = false;
  final TextEditingController stokProdukController = TextEditingController();
  final TextEditingController minimumStockController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stockData = await _dbHelper.getStockData(widget.productId);
    if (stockData != null) {
      setState(() {
        stokProdukController.text = stockData['stokProduk'];
        minimumStockController.text = stockData['minimumStock'];
        _isChecked = stockData['isChecked'] == 1;
      });
    }
  }

  Future<void> _saveData() async {
    await _dbHelper.saveStockData(
      widget.productId,
      stokProdukController.text,
      minimumStockController.text,
      _isChecked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Set background color
      appBar: AppBar(
        title: const Text('Kelola Stok'),
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: stokProdukController,
                  decoration: const InputDecoration(
                    labelText: 'Stok Produk',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: minimumStockController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Stock',
                  ),
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: const Text(
                      'Kirim notifikasi saat stok mencapai batas minimum'),
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    await _saveData();
                    Navigator.pop(context, {
                      'stokProduk': stokProdukController.text,
                      'minimumStock': minimumStockController.text,
                      'isChecked': _isChecked,
                    });
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

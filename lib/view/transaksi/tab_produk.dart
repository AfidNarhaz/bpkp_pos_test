import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

class ProdukTab extends StatefulWidget {
  const ProdukTab({super.key});

  @override
  ProdukTabState createState() => ProdukTabState();
}

class ProdukTabState extends State<ProdukTab> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _listKategori = [];
  List<Map<String, dynamic>> _allProduk = [];
  List<Map<String, dynamic>> _filteredProduk = [];
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _loadKategoriAsync();
    _loadProdukAsync();
  }

  Future<void> _loadKategoriAsync() async {
    final data = await dbHelper.getKategori();
    setState(() {
      _listKategori = data;
      if (_listKategori.isNotEmpty) {
        _selectedKategori = _listKategori.first['name'];
        _filterProdukByKategori(_selectedKategori!);
      }
    });
  }

  Future<void> _loadProdukAsync() async {
    final data = await dbHelper.getProduks();
    setState(() {
      _allProduk = data.map((produk) => produk.toMap()).toList();
      if (_selectedKategori != null) {
        _filterProdukByKategori(_selectedKategori!);
      }
    });
  }

  void _filterProdukByKategori(String kategori) {
    setState(() {
      _filteredProduk =
          _allProduk.where((produk) => produk['kategori'] == kategori).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_listKategori.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Pilih Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedKategori,
                      items: _listKategori
                          .map((kategori) => DropdownMenuItem<String>(
                                value: kategori['name'],
                                child: Text(kategori['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKategori = value;
                          _filterProdukByKategori(value!);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _filteredProduk.isNotEmpty
              ? ListView.builder(
                  itemCount: _filteredProduk.length,
                  itemBuilder: (context, index) {
                    final produk = _filteredProduk[index];
                    return ListTile(
                      title: Text(produk['nama']),
                      subtitle:
                          Text('Rp.${_formatCurrency(produk['hargaJual'])}'),
                      // subtitle: Text(
                      //     'Rp.${_formatCurrency(filteredProdukList[index].hargaJual)}'),
                    );
                  },
                )
              : const Center(child: Text('Tidak ada produk tersedia')),
        ),
      ],
    );
  }

  // Fungsi _formatCurrency
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

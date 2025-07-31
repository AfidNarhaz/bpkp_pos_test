import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProdukTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  const ProdukTab({super.key, required this.onAddToCart});

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
    _loadKategoriAsync(); // PENTING: jangan dihapus
    _loadProdukAsync(); // PENTING: jangan dihapus
  }

  Future<void> _loadKategoriAsync() async {
    final data = await dbHelper.getKategori();
    setState(() {
      // Tambahkan "Semua" di awal list
      _listKategori = [
            {'name': 'Semua'}
          ] +
          data
              .map<Map<String, String>>((kategori) =>
                  kategori.map((key, value) => MapEntry(key, value.toString())))
              .toList();

      _selectedKategori = 'Semua';
      _filterProdukByKategori(_selectedKategori!);
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
      if (kategori == 'Semua') {
        _filteredProduk = List.from(_allProduk);
      } else {
        _filteredProduk = _allProduk
            .where((produk) => produk['kategori'] == kategori)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_listKategori.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                    if (value != null) {
                      _selectedKategori = value;
                      _filterProdukByKategori(value);
                    }
                  },
                ),
              ),
            ),
          ),
        Expanded(
          child: _filteredProduk.isNotEmpty
              ? ListView.builder(
                  itemCount: _filteredProduk.length,
                  itemBuilder: (context, index) {
                    final produk = _filteredProduk[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: (produk['imagePath'] != null &&
                                  produk['imagePath'].toString().isNotEmpty)
                              ? Image.file(
                                  File(produk['imagePath']),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 56),
                          title: Text(produk['nama']),
                          subtitle: Text(
                              'Rp.${_formatCurrency(produk['hargaJual'])}'),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          visualDensity: VisualDensity.compact,
                          onTap: () {
                            widget.onAddToCart(
                                produk); // produk adalah Map<String, dynamic>
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : const Center(child: Text('Tidak ada produk tersedia')),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

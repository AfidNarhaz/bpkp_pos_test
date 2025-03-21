import 'dart:io';

import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';

class StokTab extends StatefulWidget {
  const StokTab({super.key});

  @override
  StokTabState createState() => StokTabState();
}

class StokTabState extends State<StokTab> {
  List<Produk> produkList = [];
  List<Produk> filteredStocks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProdukAsync();
    _searchController.addListener(() {
      _filterStocks(_searchController.text);
    });
  }

  Future<void> _loadProdukAsync() async {
    try {
      List<Produk> products = await DatabaseHelper().getProduks();
      setState(() {
        produkList = products;
        filteredStocks = produkList;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  void _filterStocks(String query) {
    setState(() {
      filteredStocks = produkList
          .where((produk) =>
              produk.nama.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showFilterDialog(BuildContext context) {
    // Implement filter dialog
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
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredStocks.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada stok ditemukan',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStocks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                8.0), // Atur ketajaman tepi di sini
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
                          'Stok: ${filteredStocks[index].stok ?? 0}, Min Stok: ${filteredStocks[index].minStok ?? 0}, Satuan: ${filteredStocks[index].satuan ?? ''}',
                        ),
                        onTap: () async {
                          // Implement edit stock
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

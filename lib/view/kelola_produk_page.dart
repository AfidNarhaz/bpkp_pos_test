import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk encoding dan decoding JSON
import 'tambah_produk_page.dart';

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key});

  @override
  KelolaProdukPageState createState() => KelolaProdukPageState();
}

class KelolaProdukPageState extends State<KelolaProdukPage> {
  List<String> produkList = [];
  List<String> filteredProdukList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    _loadProdukAsync(); // Memuat produk secara async
  }

  Future<void> _loadProdukAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? produkData = prefs.getString('produkList');

    if (produkData != null) {
      setState(() {
        produkList = List<String>.from(json.decode(produkData));
        filteredProdukList = produkList;
      });
    }
    setState(() {
      _isLoading = false; // Ubah status loading setelah data dimuat
    });
  }

  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((produk) => produk.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _tambahProduk() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahProdukPage()),
    );

    if (result != null) {
      setState(() {
        produkList.add(result['nama']);
        filteredProdukList = produkList;
      });
      _saveProdukList(); // Simpan daftar produk ke local storage
    }
  }

  Future<void> _saveProdukList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('produkList', json.encode(produkList));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah tab (Produk, Stok, Penjualan)
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 186, 227, 236),
        appBar: AppBar(
          title: const Text(
            'Kelola Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Produk'),
              Tab(text: 'Stok'),
              Tab(text: 'Penjualan'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(), // Tampilkan loading indicator
              )
            : TabBarView(
                children: [
                  _buildProdukTab(), // Tab Produk
                  _buildStokTab(), // Tab Stok
                  _buildPenjualanTab(), // Tab Penjualan
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _tambahProduk,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Konten untuk Tab Produk
  Widget _buildProdukTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredProdukList.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredProdukList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredProdukList[index]),
                    );
                  },
                )
              : const Center(
                  child: Text('Tidak ada produk ditemukan'),
                ),
        ),
      ],
    );
  }

  // Konten untuk Tab Stok
  Widget _buildStokTab() {
    return const Center(
      child: Text(
        'Konten Stok',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  // Konten untuk Tab Penjualan
  Widget _buildPenjualanTab() {
    return const Center(
      child: Text(
        'Konten Penjualan',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

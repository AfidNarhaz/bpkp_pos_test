import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/pegawai/tambah_pegawai_page.dart';

// package:bpkp_pos_test/view/kelola_produk_page.dart

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  List<Product> produkList = [];
  List<Product> filteredProdukList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    _loadProdukAsync(); // Memuat produk secara async
  }

  Future<void> _loadProdukAsync() async {
    List<Product> products = await dbHelper.getProducts();
    setState(() {
      produkList = products;
      filteredProdukList = produkList;
      _isLoading = false;
    });
  }

  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((produk) => produk.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _tambahProduk() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahPegawaiPage()),
    );

    if (result != null) {
      Product newProduct = Product(
        name: result['nama'],
        brand: result['brand'],
        category: result['category'],
        price: double.parse(result['price']),
      );
      await dbHelper.insertProduct(newProduct);
      _loadProdukAsync(); // Refresh data
    }
  }

  Future<void> _editProduk(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahPegawaiPage(
          produk: produkList[index], // Kirim produk yang akan di-edit
        ),
      ),
    );

    if (result != null) {
      Product updatedProduct = Product(
        id: produkList[index].id,
        name: result['nama'],
        brand: result['brand'],
        category: result['category'],
        price: double.parse(result['price']),
      );
      await dbHelper.updateProduct(updatedProduct);
      _loadProdukAsync(); // Refresh data
    }
  }

  Future<void> _deleteProduk(int index) async {
    await dbHelper.deleteProduct(produkList[index].id!);
    _loadProdukAsync(); // Refresh data
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 186, 227, 236),
        appBar: AppBar(
          title: const Text(
            'Transaksi',
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
              Tab(text: 'Manual'),
              Tab(text: 'Produk'),
              Tab(text: 'Favorite'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  _buildProdukTab(),
                  _buildStokTab(),
                  _buildPenjualanTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _tambahProduk,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

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
                      title: Text(filteredProdukList[index].name),
                      onTap: () => _editProduk(index),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduk(index),
                      ),
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

  Widget _buildStokTab() {
    return const Center(
      child: Text(
        'Konten Stok',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildPenjualanTab() {
    return const Center(
      child: Text(
        'Konten Penjualan',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

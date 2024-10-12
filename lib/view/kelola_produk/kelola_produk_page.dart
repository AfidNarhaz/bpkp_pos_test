import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'tambah_produk_page.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('KelolaProdukLogger');

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key});

  @override
  KelolaProdukPageState createState() => KelolaProdukPageState();
}

class KelolaProdukPageState extends State<KelolaProdukPage> {
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
    setState(() {
      _isLoading = true; // Tampilkan loading
    });

    try {
      List<Product> products = await dbHelper.getProducts();
      setState(() {
        produkList = products;
        filteredProdukList = produkList;
      });
    } catch (e) {
      _logger.severe('Error loading products: $e');
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading setelah selesai
      });
    }
  }

  void _filterProduk() {
    _logger.info('Filtering produk...');
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((produk) => produk.name.toLowerCase().contains(query))
          .toList();
    });
    _logger.info('Filter selesai.');
  }

  Future<void> _tambahProduk() async {
    _logger.info('Navigating to TambahProdukPage...');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahProdukPage()),
    );

    if (result != null) {
      // Create new product object from the result
      Product newProduct = Product(
        name: result['nama'],
        brand: result['brand'],
        category: result['category'],
        price: double.parse(result['price']),
        isFavorite: result['isFavorite'], // Add isFavorite field
      );
      // Save product to the database
      await dbHelper.insertProduct(newProduct);
      _loadProdukAsync(); // Refresh product list
    }
  }

  Future<void> _editProduk(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahProdukPage(
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
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Kelola Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorSize:
                TabBarIndicatorSize.tab, // Menyesuaikan panjang dengan tab
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: AppColors.text, // Lebar dan warna garis
              ),
            ),
            labelColor: AppColors.text, // Warna teks untuk tab yang dipilih
            unselectedLabelColor:
                AppColors.hidden, // Warna teks untuk tab yang tidak dipilih
            tabs: const [
              Tab(text: 'Produk'),
              Tab(text: 'Kategori'),
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
                  _buildKategoriTab(),
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
                    hintText: 'Cari Produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
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
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: filteredProdukList[index].isFavorite
                            ? const Icon(Icons.star, color: Colors.yellow)
                            : null, // Show star if favorite
                      ),
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

  Widget _buildKategoriTab() {
    return const Center(
      child: Text(
        'Konten Penjualan',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/detail_produk_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/tambah_produk_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_kategori/kategori.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/kelola_stok.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:io';

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
  List<Map<String, dynamic>> _listKategori = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    _loadProdukAsync();
    _loadKategoriAsync();
  }

  void _filterProductsByCategory(List<String> selectedCategories) {
    setState(() {
      if (selectedCategories.isEmpty) {
        // Jika tidak ada kategori yang dipilih, tampilkan semua produk
        filteredProdukList = produkList;
      } else {
        // Filter produk berdasarkan kategori yang dipilih
        filteredProdukList = produkList
            .where((product) => selectedCategories.contains(product.kategori))
            .toList();
      }
    });
  }

  Future<void> _loadProdukAsync() async {
    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    List<bool> selectedCategories =
        List<bool>.filled(_listKategori.length, false);
    TextEditingController searchCategoryController = TextEditingController();
    List<Map<String, dynamic>> filteredKategoriList =
        _listKategori; // Mulai dengan semua kategori

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Kategori'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setState) {
                // Fungsi untuk memfilter kategori berdasarkan input pencarian
                void filterCategories() {
                  setState(() {
                    final query = searchCategoryController.text.toLowerCase();
                    filteredKategoriList = _listKategori
                        .where((kategori) =>
                            kategori['name'].toLowerCase().contains(query))
                        .toList();
                  });
                }

                searchCategoryController.addListener(filterCategories);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TextField untuk pencarian kategori
                    TextField(
                      controller: searchCategoryController,
                      decoration: InputDecoration(
                        hintText: 'Cari Kategori...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Daftar kategori yang difilter
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredKategoriList.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(filteredKategoriList[index]['name']),
                            value: selectedCategories[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedCategories[index] = value!;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Terapkan'),
              onPressed: () {
                List<String> filteredCategories = [];
                for (int i = 0; i < selectedCategories.length; i++) {
                  if (selectedCategories[i]) {
                    filteredCategories.add(_listKategori[i]['name']);
                  }
                }

                _filterProductsByCategory(filteredCategories);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadKategoriAsync() async {
    try {
      List<Map<String, dynamic>> categories = await dbHelper.getKategori();
      setState(() {
        _listKategori = categories;
      });
    } catch (e) {
      _logger.severe('Error loading categories: $e');
    }
  }

  void _filterProduk() {
    _logger.info('Filtering produk...');
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProdukList = produkList
          .where((produk) => produk.nama.toLowerCase().contains(query))
          .toList();
    });
    _logger.info('Filter selesai.');
  }

  // Fungsi _parsePrice
  double _parsePrice(String? price) {
    // Hilangkan titik/koma jika ada, dan konversikan ke double
    String cleanedPrice = price?.replaceAll('.', '').replaceAll(',', '') ?? '0';
    return double.tryParse(cleanedPrice) ?? 0.0;
  }

  // Fungsi _formatCurrency
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future<void> _tambahProduk() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahProdukPage(
          onProductAdded: () async {
            await _loadProdukAsync(); // Reload the product list
          },
        ),
      ),
    );

    // Logger(result); // Debug print untuk melihat nilai result

    // Pastikan result adalah Map<String, dynamic> yang sesuai
    if (result != null && result is Map<String, dynamic>) {
      if (mounted) {
        Product newProduct = Product(
          nama: result['nama'] as String? ?? '',
          kategori: result['category'] as String? ?? '',
          merek: result['brand'] as String? ?? '',
          kode: result['kode'] as String? ?? '',
          hargaModal: _parsePrice(result['hargaModal'] as String? ?? '0'),
          hargaJual: _parsePrice(result['price'] as String? ?? '0'),
          tanggalKadaluwarsa: result['tanggalKadaluwarsa'] as String? ?? '',
          isFavorite: result['isFavorite'] as bool? ?? false,
          imagePath: result['imagePath'] as String? ?? '',
        );

        await dbHelper.insertProduct(newProduct);
        await _loadProdukAsync(); // Ensure the product list is reloaded
      }
    }
  }

  Future<void> _deleteProduk(int index) async {
    await dbHelper.deleteProduct(produkList[index].id!);
    _loadProdukAsync();
  }

  // Removed unused _navigateToDetailProdukPage method

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Update the length to 3
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Kelola Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: AppColors.text,
              ),
            ),
            labelColor: AppColors.text,
            unselectedLabelColor: AppColors.hidden,
            tabs: [
              Tab(text: 'Produk'),
              Tab(text: 'Stok'), // Add new tab for Stok
              Tab(text: 'Kategori'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildProdukTab(),
                  _buildStokTab(), // Add new Stok tab content
                  _buildKategoriTab(),
                ],
              ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                return Visibility(
                  visible: tabController.index == 0 || tabController.index == 2,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (tabController.index == 0) {
                        _tambahProduk();
                      } else if (tabController.index == 2) {
                        // Add functionality for adding a new category if needed
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                );
              },
            );
          },
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
                onPressed: () {
                  _showFilterDialog(context);
                },
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
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              8.0), // Atur ketajaman tepi di sini
                          image: filteredProdukList[index].imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(
                                      filteredProdukList[index].imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.blue[100],
                        ),
                      ),
                      title: Row(
                        children: [
                          if (filteredProdukList[index].isFavorite)
                            const Icon(Icons.star, color: Colors.yellow),
                          Text(filteredProdukList[index].nama),
                        ],
                      ),
                      subtitle: Text(
                          'Rp.${_formatCurrency(filteredProdukList[index].hargaJual)}'),
                      onTap: () async {
                        final updatedProduk = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailProdukPage(
                                produk: filteredProdukList[index]),
                          ),
                        );

                        if (updatedProduk != null) {
                          setState(() {
                            filteredProdukList[index] = updatedProduk;
                          });
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Yakin Ingin Menghapus Produk Ini?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text(
                                      'Yakin',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteProduk(index);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                )
              : const Center(child: Text('Tidak ada produk ditemukan')),
        ),
      ],
    );
  }

  Widget _buildStokTab() {
    return StokTab(); // Use the existing KelolaStokPage content
  }

  Widget _buildKategoriTab() {
    return KategoriTab(); // Use the existing KelolaStokPage content
  }
}

import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/detail_produk_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/add_produk_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_kategori/kategori.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/atur_stok.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:bpkp_pos_test/view/kelola_produk/tab_kategori/add_kategori.dart';

final Logger _logger = Logger('KelolaProdukLogger');

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key});

  @override
  KelolaProdukPageState createState() => KelolaProdukPageState();
}

class KelolaProdukPageState extends State<KelolaProdukPage> {
  List<Produk> produkList = [];
  List<Produk> filteredProdukList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    _loadProdukAsync(); // Kembalikan pemanggilan ini agar data produk di-load saat init
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
      List<Produk> products = await dbHelper.getProduks();
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
    TextEditingController searchCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper.getKategori(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const AlertDialog(content: Text('Gagal memuat kategori'));
            }
            final kategoriList = snapshot.data ?? [];
            List<bool> selectedCategories =
                List<bool>.filled(kategoriList.length, false);
            List<Map<String, dynamic>> filteredKategoriList =
                List.from(kategoriList);
            return StatefulBuilder(
              builder: (context, setState) {
                void filterCategories() {
                  setState(() {
                    final query = searchCategoryController.text.toLowerCase();
                    filteredKategoriList = kategoriList
                        .where((kategori) =>
                            kategori['name'].toLowerCase().contains(query))
                        .toList();
                  });
                }

                searchCategoryController.addListener(filterCategories);
                return AlertDialog(
                  title: const Text('Filter Kategori'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredKategoriList.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                title:
                                    Text(filteredKategoriList[index]['name']),
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
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Reset'),
                      onPressed: () {
                        setState(() {
                          for (int i = 0; i < selectedCategories.length; i++) {
                            selectedCategories[i] = false;
                          }
                          filteredKategoriList = List.from(kategoriList);
                          searchCategoryController.clear();
                        });
                        Navigator.of(context).pop();
                        _showFilterDialog(context);
                      },
                    ),
                    TextButton(
                      child: const Text('Batal'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Filter'),
                      onPressed: () {
                        List<String> filteredCategories = [];
                        for (int i = 0; i < selectedCategories.length; i++) {
                          if (selectedCategories[i]) {
                            filteredCategories.add(kategoriList[i]['name']);
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
          },
        );
      },
    );
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

  Future<void> _addProduk() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProdukPage(
          onProdukAdded: () async {
            await _loadProdukAsync(); // Reload the product list
          },
        ),
      ),
    );

    // Logger(result); // Debug print untuk melihat nilai result

    // Pastikan result adalah Map<String, dynamic> yang sesuai
    if (result != null && result is Map<String, dynamic>) {
      if (mounted) {
        Produk newProduct = Produk(
          nama: result['nama'] as String? ?? '',
          kategori: result['category'] as String? ?? '',
          merek: result['brand'] as String? ?? '',
          barcode: result['barcode'] as String? ?? '',
          hargaBeli: _parsePrice(result['hargaBeli'] as String? ?? '0'),
          hargaJual: _parsePrice(result['price'] as String? ?? '0'),
          tglExpired: result['tglExpired'] as String? ?? '',
          imagePath: result['imagePath'] as String? ?? '',
        );

        await dbHelper.insertProduk(newProduct);
        await _loadProdukAsync(); // Ensure the product list is reloaded
      }
    }
  }

  Future<void> _deleteProduk(int index) async {
    await dbHelper.deleteProduk(produkList[index].id!);
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
      length: 3,
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
              Tab(text: 'Kategori'),
              Tab(text: 'Stok'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildProdukTab(),
                  _buildKategoriTab(),
                  _buildStokTab(),
                ],
              ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                return Visibility(
                  visible: tabController.index == 0 || tabController.index == 1,
                  child: FloatingActionButton(
                    onPressed: () async {
                      if (tabController.index == 0) {
                        _addProduk();
                      } else if (tabController.index == 1) {
                        // Tampilkan dialog tambah kategori
                        final namaKategori =
                            await showAddKategoriDialog(context);
                        if (namaKategori != null && namaKategori.isNotEmpty) {
                          await dbHelper.insertKategori(namaKategori);
                          setState(() {}); // Refresh kategori tab
                        }
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
                                      backgroundColor: AppColors.background,
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: AppColors.text),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                    ),
                                    child: const Text(
                                      'Yakin',
                                      style: TextStyle(color: AppColors.text),
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
    return StokTab();
  }

  Widget _buildKategoriTab() {
    return KategoriTab(); // Use the existing KelolaStokPage content
  }
}

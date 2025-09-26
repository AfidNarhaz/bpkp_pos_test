import 'package:bpkp_pos_test/view/produk/tab_produk/add_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_stok/stok.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/list_tile_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/searchfilter_bar.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/filter_dialog.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/produk_tab_bar_view.dart';

final Logger _logger = Logger('KelolaProdukLogger');

class KelolaProdukPage extends StatefulWidget {
  const KelolaProdukPage({super.key});

  @override
  KelolaProdukPageState createState() => KelolaProdukPageState();
}

class KelolaProdukPageState extends State<KelolaProdukPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Produk> produkList = [];
  List<Produk> filteredProdukList = [];
  final TextEditingController _searchController = TextEditingController();

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Ubah jadi 2 tab

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // hindari trigger berulang
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });

    _searchController.addListener(_filterProduk);
    _loadProdukAsync();
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
    try {
      List<Produk> products = await dbHelper.getProduks();
      if (mounted) {
        setState(() {
          produkList = products;
          filteredProdukList = produkList;
        });
      }
    } catch (e) {
      _logger.severe('Error loading products: $e');
    }
  }

  void _showFilterDialog(BuildContext context) async {
    final kategoriList = await dbHelper.getKategori();
    List<bool> selectedCategories =
        List<bool>.filled(kategoriList.length, false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          kategoriList: kategoriList,
          selectedCategories: selectedCategories,
          onFilter: (filteredCategories) {
            _filterProductsByCategory(filteredCategories);
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProdukTabBarView(
      tabs: const [
        Tab(text: 'Produk'),
        Tab(text: 'Stok'),
      ],
      tabViews: [
        _buildProdukTab(),
        _buildStokTab(),
      ],
      tabController: _tabController,
      floatingActionButton: _buildFabByTab(),
    );
  }

  Widget _buildProdukTab() {
    return Column(
      children: [
        SearchAndFilterBar(
          searchController: _searchController,
          onFilter: () {
            _showFilterDialog(context);
          },
        ),
        Expanded(
          child: filteredProdukList.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredProdukList.length,
                  itemBuilder: (context, index) {
                    return ListTileProduk(
                      produk: filteredProdukList[index],
                      onUpdated: () async {
                        await _loadProdukAsync();
                      },
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

  Widget? _buildFabByTab() {
    if (_currentTabIndex == 0) {
      // FAB untuk tambah produk
      return FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProdukPage(
                onProdukAdded: () async {
                  await _loadProdukAsync();
                },
              ),
            ),
          );
        },
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  int get _currentTabIndex => _tabController.index;
}

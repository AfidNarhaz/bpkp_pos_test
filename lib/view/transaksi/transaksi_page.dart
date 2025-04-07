import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  bool _isSheetExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manual'),
              Tab(text: 'Produk'),
              Tab(text: 'Favorite'),
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                children: [
                  const ManualTabContent(),
                  const ProdukTabContent(),
                  const FavoriteTabContent(),
                ],
              ),
              _buildDraggableSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        setState(() {
          _isSheetExpanded = notification.extent > 0.3;
        });
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: DraggableSheetContent(
              scrollController: scrollController,
              onToggle: () {
                setState(() {
                  _isSheetExpanded = !_isSheetExpanded;
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class FavoriteTabContent extends StatelessWidget {
  const FavoriteTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Favorite',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class DraggableSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onToggle;

  const DraggableSheetContent({
    required this.scrollController,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < 0) {
                onToggle();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.drag_handle),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 10,
              itemBuilder: (context, index) => ListTile(
                title: Text('Produk ${index + 1}'),
                subtitle: const Text('Detail produk'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManualTabContent extends StatefulWidget {
  const ManualTabContent({super.key});

  @override
  ManualTabContentState createState() => ManualTabContentState();
}

class ManualTabContentState extends State<ManualTabContent> {
  String displayText = 'Rp0';
  double total = 0;
  final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

  void _onButtonPressed(String value) {
    setState(() {
      if (displayText == 'Rp0') {
        displayText = 'Rp$value';
      } else {
        displayText += value;
      }
      total = double.tryParse(
              displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
          0;
      displayText = 'Rp${currencyFormatter.format(total)}';
    });
  }

  void _onDelete() {
    setState(() {
      if (displayText.length > 3) {
        displayText = displayText.substring(0, displayText.length - 1);
        total = double.tryParse(
                displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
            0;
        displayText =
            total > 0 ? 'Rp${currencyFormatter.format(total)}' : 'Rp0';
      } else {
        displayText = 'Rp0';
      }
    });
  }

  void _onClear() {
    setState(() {
      displayText = 'Rp0';
      total = 0;
    });
  }

  void _onAddToCart() {
    final logger = Logger('TransaksiPage');
    logger.info('Produk ditambahkan ke keranjang: $total');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            // flex: 2,
            child: Container(
              color: Colors.grey[200],
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: Text(
                displayText,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            // flex: 5,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Table(
                      border: TableBorder.all(color: Colors.transparent),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _buildTableRow(['1', '2', '3']),
                        _buildTableRow(['4', '5', '6']),
                        _buildTableRow(['7', '8', '9']),
                        _buildTableRow(['0', '000', 'C']),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildIconButton(Icons.backspace, _onDelete),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildCartButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> labels) {
    return TableRow(
      children: labels.map((label) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                if (label == 'C') {
                  _onClear();
                } else {
                  _onButtonPressed(label);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(label, style: const TextStyle(fontSize: 20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Icon(icon, size: 16),
    );
  }

  Widget _buildCartButton() {
    return ElevatedButton(
      onPressed: _onAddToCart,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 16),
        ],
      ),
    );
  }
}

class ProdukTabContent extends StatefulWidget {
  const ProdukTabContent({super.key});

  @override
  ProdukTabContentState createState() => ProdukTabContentState();
}

class ProdukTabContentState extends State<ProdukTabContent> {
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
      _allProduk = data
          .map((produk) => produk.toMap())
          .toList(); // Ensure Produk has a toMap() method
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

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_listKategori.isNotEmpty)
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
                      subtitle: Text(
                          'Harga: Rp.${_formatCurrency(produk['hargaJual'])}'),
                    );
                  },
                )
              : const Center(child: Text('Tidak ada produk tersedia')),
        ),
      ],
    );
  }
}

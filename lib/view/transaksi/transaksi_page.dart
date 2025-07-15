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
  String displayText = 'Rp0';
  double total = 0;
  final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Transaksi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              Tab(text: 'Manual'),
              Tab(text: 'Produk'),
              Tab(text: 'Favorite'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Display angka
            Container(
              height: 100,
              color: Colors.grey.shade200,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(16),
              child: Text(
                displayText,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            // Keypad dan tombol kanan
            Expanded(
              child: Row(
                children: [
                  // Tombol angka
                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      padding: const EdgeInsets.all(8),
                      children: [
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '9',
                        '0',
                        '000',
                        'C',
                      ].map((text) => KeyButton(text: text)).toList(),
                    ),
                  ),
                  // Tombol kanan (hapus & keranjang)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.backspace_outlined),
                            onPressed: _onDelete,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('PRO',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 10)),
                              Icon(Icons.add_shopping_cart),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tombol Tagih
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Tagih = Rp20.000'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyButton extends StatelessWidget {
  final String text;
  const KeyButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 20)),
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
          SizedBox(
            height: 100, // Atur tinggi tetap agar tidak terlalu besar
            width: double.infinity,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(12), // Sedikit kurangi padding
              alignment: Alignment.centerRight,
              child: Text(
                displayText,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold), // Sedikit perbesar font
              ),
            ),
          ),
          Expanded(
            // flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0), // Kurangi padding vertikal
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Table(
                      border: TableBorder.all(color: Colors.transparent),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            _buildTableButton('1'),
                            _buildTableButton('2'),
                            _buildTableButton('3'),
                            _buildIconButtonCell(Icons.backspace, _onDelete),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableButton('4'),
                            _buildTableButton('5'),
                            _buildTableButton('6'),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.fill,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: _buildCartButtonStack()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableButton('7'),
                            _buildTableButton('8'),
                            _buildTableButton('9'),
                            Container(), // Kosong, biar Stack di atas tetap menutupi
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableButton('0'),
                            _buildTableButton('000'),
                            _buildTableButton('C'),
                            Container(), // Kosong, biar Stack di atas tetap menutupi
                          ],
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

  Widget _buildTableButton(String label) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: 48,
        width: double.infinity,
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
            padding: EdgeInsets.zero,
          ),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildIconButtonCell(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildCartButtonStack() {
    // Tombol keranjang memanjang 3 baris
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: 48 * 3 + 8, // 3 baris tombol + padding antar baris
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _onAddToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart, size: 22),
              const SizedBox(height: 2),
              const Text('Keranjang', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
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
  String? _selectedKategori;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getKategori(),
      builder: (context, kategoriSnapshot) {
        if (kategoriSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (kategoriSnapshot.hasError) {
          return const Center(child: Text('Gagal memuat kategori'));
        }
        final listKategori = kategoriSnapshot.data ?? [];
        _selectedKategori ??=
            listKategori.isNotEmpty ? listKategori.first['name'] : null;
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper
              .getProduks()
              .then((produkList) => produkList.map((p) => p.toMap()).toList()),
          builder: (context, produkSnapshot) {
            if (produkSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (produkSnapshot.hasError) {
              return const Center(child: Text('Gagal memuat produk'));
            }
            final allProduk = produkSnapshot.data ?? [];
            final filteredProduk = allProduk
                .where((produk) =>
                    _selectedKategori == null ||
                    produk['kategori'] == _selectedKategori)
                .toList();
            return Column(
              children: [
                if (listKategori.isNotEmpty)
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
                              items: listKategori
                                  .map((kategori) => DropdownMenuItem<String>(
                                        value: kategori['name'],
                                        child: Text(kategori['name']),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedKategori = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: filteredProduk.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredProduk.length,
                          itemBuilder: (context, index) {
                            final produk = filteredProduk[index];
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
          },
        );
      },
    );
  }

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(amount);
  }
}

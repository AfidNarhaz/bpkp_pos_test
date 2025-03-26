import 'package:bpkp_pos_test/view/transaksi/tab_manual.dart';
import 'package:bpkp_pos_test/view/transaksi/tab_produk.dart';
import 'package:flutter/material.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  TransaksiPageState createState() => TransaksiPageState();
}

class TransaksiPageState extends State<TransaksiPage> {
  final bool _isSheetExpanded = false;

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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manual'),
              Tab(text: 'Produk'),
              Tab(text: 'Favorite'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                ManualTab(),
                ProdukTab(),
                _buildFavoriteTab(),
              ],
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.2,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Optional: Add functionality for tapping the handle
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.drag_handle),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 20,
                          itemBuilder: (context, index) => ListTile(
                            title: Text('Produk ${index + 1}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              // onDragUpdate: (details) {
              //   setState(() {
              //     _isSheetExpanded = details.extent > 0.3;
              //   });
              // },
            ),
            if (!_isSheetExpanded)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    // Add your "Tagih" button action here
                  },
                  child: const Text(
                    'Tagih = Rp0',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteTab() {
    return const Center(
      child: Text(
        'Favorite',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

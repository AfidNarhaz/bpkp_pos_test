import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class StokTab extends StatefulWidget {
  const StokTab({super.key});

  @override
  StokTabState createState() => StokTabState();
}

class StokTabState extends State<StokTab> {
  List<String> filteredStocks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _showFilterDialog(BuildContext context) {
    // Implement filter dialog
  }

  void _filterStocks(String query) {
    // Implement the filter logic here
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
                    onChanged: _filterStocks,
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
                        title: Text(filteredStocks[index]),
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

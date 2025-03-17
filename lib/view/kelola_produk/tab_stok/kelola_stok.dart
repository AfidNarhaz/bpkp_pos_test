import 'package:flutter/material.dart';

class StokTab extends StatefulWidget {
  const StokTab({super.key});

  @override
  StokTabState createState() => StokTabState();
}

class StokTabState extends State<StokTab> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allStocks = [
    'Product 1',
    'Product 2',
    'Product 3'
  ]; // Example data
  List<String> _filteredStocks = [];

  @override
  void initState() {
    super.initState();
    _filteredStocks = _allStocks;
  }

  void _filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStocks = _allStocks;
      } else {
        _filteredStocks = _allStocks
            .where((stock) => stock.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterStocks,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStocks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredStocks[index]),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Cancel changes
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Batal'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Save changes
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Simpan'),
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

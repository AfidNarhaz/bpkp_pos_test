import 'package:bpkp_pos_test/view/produk/widget/barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilter;
  final ValueChanged<String> onSearchByName;
  final ValueChanged<String> onSearchByBarcode;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onFilter,
    required this.onSearchByName,
    required this.onSearchByBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari Produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: onSearchByName,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              MdiIcons.barcodeScan,
              size: 30,
            ),
            onPressed: () async {
              final barcode = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerPage(),
                ),
              );
              if (barcode != null && barcode.isNotEmpty) {
                searchController.text = barcode;
                onSearchByBarcode(barcode);
              }
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilter;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onFilter,
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
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: onFilter,
          ),
        ],
      ),
    );
  }
}

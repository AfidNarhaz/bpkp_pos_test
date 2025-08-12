import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final List<Map<String, dynamic>> kategoriList;
  final List<bool> selectedCategories;
  final ValueChanged<List<String>> onFilter;

  const FilterDialog({
    super.key,
    required this.kategoriList,
    required this.selectedCategories,
    required this.onFilter,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late List<Map<String, dynamic>> filteredKategoriList;
  late TextEditingController searchCategoryController;
  late List<bool> selectedCategories;

  @override
  void initState() {
    super.initState();
    filteredKategoriList = List.from(widget.kategoriList);
    searchCategoryController = TextEditingController();
    selectedCategories = List.from(widget.selectedCategories);

    searchCategoryController.addListener(_filterCategories);
  }

  void _filterCategories() {
    final query = searchCategoryController.text.toLowerCase();
    setState(() {
      filteredKategoriList = widget.kategoriList
          .where((kategori) => kategori['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  final idx =
                      widget.kategoriList.indexOf(filteredKategoriList[index]);
                  return CheckboxListTile(
                    title: Text(filteredKategoriList[index]['name']),
                    value: selectedCategories[idx],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedCategories[idx] = value!;
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
              filteredKategoriList = List.from(widget.kategoriList);
              searchCategoryController.clear();
            });
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
                filteredCategories.add(widget.kategoriList[i]['name']);
              }
            }
            widget.onFilter(filteredCategories);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

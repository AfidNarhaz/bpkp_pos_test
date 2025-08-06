import 'package:flutter/material.dart';

Future<String?> showAddKategoriDialog(BuildContext context,
    {Function()? onKategoriAdded}) async {
  final TextEditingController kategoriController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: kategoriController,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  kategoriController.clear();
                },
                child: const Text('Hapus'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  final namaKategori = kategoriController.text.trim();
                  if (namaKategori.isNotEmpty) {
                    Navigator.of(context).pop(namaKategori);
                    if (onKategoriAdded != null) onKategoriAdded();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ],
      );
    },
  );
}

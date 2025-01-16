import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('KategoriDialogLogger');

class KategoriDialog extends StatelessWidget {
  final int index;
  final List<Map<String, dynamic>> listKategori;
  final DatabaseHelper dbHelper;
  final VoidCallback onUpdate;

  const KategoriDialog({
    super.key,
    required this.index,
    required this.listKategori,
    required this.dbHelper,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController editController =
        TextEditingController(text: listKategori[index]['name']);

    return AlertDialog(
      title: const Text('Edit Kategori'),
      content: TextField(
        controller: editController,
        decoration: const InputDecoration(labelText: 'Nama Kategori'),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Hapus'),
          onPressed: () async {
            await _deleteKategori(context);
          },
        ),
        TextButton(
          child: const Text('Simpan'),
          onPressed: () async {
            await _updateKategori(context, editController.text);
          },
        ),
      ],
    );
  }

  Future<void> _updateKategori(BuildContext context, String newName) async {
    try {
      final kategoriId = listKategori[index]['id'];
      await dbHelper.updateKategori(kategoriId, newName);
      onUpdate(); // Memperbarui daftar kategori
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      _logger.info('Kategori berhasil diperbarui');
    } catch (e) {
      _logger.severe('Error updating category: $e');
    }
  }

  Future<void> _deleteKategori(BuildContext context) async {
    try {
      final kategoriId = listKategori[index]['id'];
      await dbHelper.deleteKategori(kategoriId);
      onUpdate(); // Memperbarui daftar kategori
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      _logger.info('Kategori berhasil dihapus');
    } catch (e) {
      _logger.severe('Error deleting category: $e');
    }
  }
}

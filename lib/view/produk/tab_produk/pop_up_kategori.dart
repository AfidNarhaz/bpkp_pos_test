import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class KategoriDialog {
  static void showKategoriDialog(
    BuildContext context,
    List<Map<String, dynamic>> listKategori,
    Function(String) onKategoriAdded,
    Function(int, String) onKategoriEdited,
    Function(int) onKategoriDeleted,
    Function(String) onKategoriSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showTambahKategoriDialog(context, onKategoriAdded);
                      },
                      icon: const Icon(Icons.add, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: listKategori.length,
                  itemBuilder: (context, index) {
                    final kategori = listKategori[index];
                    return ListTile(
                      title: Text(kategori['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditKategoriDialog(
                            context,
                            kategori['id'],
                            kategori['name'],
                            onKategoriEdited,
                            onKategoriDeleted,
                          );
                        },
                      ),
                      onTap: () {
                        // Mengirimkan nama kategori yang dipilih
                        onKategoriSelected(kategori['name']);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showTambahKategoriDialog(
    BuildContext context,
    Function(String) onKategoriAdded,
  ) {
    final TextEditingController kategoriBaruController =
        TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: kategoriBaruController,
                    decoration: InputDecoration(
                      labelText: 'Nama Kategori',
                      errorText: errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    String newKategori = kategoriBaruController.text.trim();
                    if (newKategori.isEmpty) {
                      setState(() {
                        errorMessage = 'Nama Kategori wajib diisi';
                      });
                    } else {
                      onKategoriAdded(newKategori);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Simpan',
                      style: TextStyle(color: AppColors.accent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showEditKategoriDialog(
    BuildContext context,
    int id,
    String existingName,
    Function(int, String) onKategoriEdited,
    Function(int) onKategoriDeleted,
  ) {
    final TextEditingController kategoriEditController =
        TextEditingController(text: existingName);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Kategori'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: kategoriEditController,
                    decoration: InputDecoration(
                      hintText: 'Nama Kategori',
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onKategoriDeleted(id);
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    String updatedKategori = kategoriEditController.text.trim();
                    if (updatedKategori.isEmpty) {
                      setState(() {
                        errorMessage = 'Kategori wajib diisi';
                      });
                    } else {
                      onKategoriEdited(id, updatedKategori);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Simpan',
                      style: TextStyle(color: AppColors.accent)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

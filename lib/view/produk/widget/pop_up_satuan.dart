import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

class SatuanDialog {
  static Future<void> showSatuanDialog(
    BuildContext context,
    List<Map<String, dynamic>> listSatuan,
    Function(String) onSatuanAdded,
    Function(int, String) onSatuanEdited,
    Function(int) onSatuanDeleted,
    Function(String) onSatuanSelected,
  ) async {
    // daftar default
    final List<String> defaultUnits = [
      'PCS',
      'BOX/DUS',
      'PACK/RCG',
      'SST',
      'BTL',
      'KLG',
    ];

    final db = DatabaseHelper();

    try {
      // Ambil list satuan di DB saat ini
      final currentSatuan = await db.getSatuan();
      final existingNames =
          currentSatuan.map((e) => e['name'].toString().toLowerCase()).toSet();

      // Insert unit default yang belum ada di DB
      for (final u in defaultUnits) {
        if (!existingNames.contains(u.toLowerCase())) {
          await db.insertSatuan(u);
        }
      }

      // Ambil ulang list setelah insert agar mendapatkan id untuk setiap item
      final updatedSatuan = await db.getSatuan();

      // Buat mergedList unik (dari DB) dan urutkan A-Z
      final mergedList = List<Map<String, dynamic>>.from(updatedSatuan);
      mergedList.sort((a, b) => a['name']
          .toString()
          .toLowerCase()
          .compareTo(b['name'].toString().toLowerCase()));

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
                        'Pilih Satuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showTambahSatuanDialog(context, (String nama) async {
                            // tambah ke DB lalu panggil callback
                            await db.insertSatuan(nama);
                            onSatuanAdded(nama);
                          });
                        },
                        icon: const Icon(Icons.add, color: AppColors.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Batas tinggi list dan aktifkan scroll
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: mergedList.length,
                      itemBuilder: (context, index) {
                        final satuan = mergedList[index];
                        final hasDbId = satuan['id'] != null;
                        return ListTile(
                          title: Text(satuan['name']),
                          trailing: hasDbId
                              ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditSatuanDialog(
                                      context,
                                      satuan['id'],
                                      satuan['name'],
                                      (int id, String newName) async {
                                        await db.updateSatuan(id, newName);
                                        onSatuanEdited(id, newName);
                                      },
                                      (int id) async {
                                        await db.deleteSatuan(id);
                                        onSatuanDeleted(id);
                                      },
                                    );
                                  },
                                )
                              : const SizedBox(width: 0, height: 0),
                          onTap: () {
                            onSatuanSelected(satuan['name']);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      // jika terjadi error DB, tampilkan dialog sederhana
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Gagal memuat satuan: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  static void _showTambahSatuanDialog(
    BuildContext context,
    Function(String) onSatuanAdded,
  ) {
    final TextEditingController satuanBaruController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nama Satuan'),
              content: TextField(
                controller: satuanBaruController,
                decoration: InputDecoration(
                  hintText: 'Nama Satuan',
                  errorText: errorMessage,
                ),
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
                    String newSatuan = satuanBaruController.text.trim();
                    if (newSatuan.isEmpty) {
                      setState(() {
                        errorMessage = 'Satuan wajib diisi';
                      });
                    } else {
                      onSatuanAdded(newSatuan);
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

  static void _showEditSatuanDialog(
    BuildContext context,
    int id,
    String existingName,
    Function(int, String) onSatuanEdited,
    Function(int) onSatuanDeleted,
  ) {
    final TextEditingController satuanEditController =
        TextEditingController(text: existingName);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Satuan'),
              content: TextField(
                controller: satuanEditController,
                decoration: InputDecoration(
                  hintText: 'Nama Satuan',
                  errorText: errorMessage,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onSatuanDeleted(id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child:
                      const Text('Hapus', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    String updatedSatuan = satuanEditController.text.trim();
                    if (updatedSatuan.isEmpty) {
                      setState(() {
                        errorMessage = 'Satuan wajib diisi';
                      });
                    } else {
                      onSatuanEdited(id, updatedSatuan);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child:
                      const Text('Simpan', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

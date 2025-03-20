import 'package:flutter/material.dart';

class SatuanDialog {
  static void showSatuanDialog(
    BuildContext context,
    List<Map<String, dynamic>> listSatuan,
    Function(String) onSatuanAdded,
    Function(int, String) onSatuanEdited,
    Function(int) onSatuanDeleted,
    Function(String) onSatuanSelected,
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
                      'Pilih Satuan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showTambahSatuanDialog(context, onSatuanAdded);
                      },
                      icon: const Icon(Icons.add, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: listSatuan.length,
                  itemBuilder: (context, index) {
                    final satuan = listSatuan[index];
                    return ListTile(
                      title: Text(satuan['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditSatuanDialog(
                            context,
                            satuan['id'],
                            satuan['name'],
                            onSatuanEdited,
                            onSatuanDeleted,
                          );
                        },
                      ),
                      onTap: () {
                        onSatuanSelected(satuan['name']);
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
                  child: const Text('Batal'),
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

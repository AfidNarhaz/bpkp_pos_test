import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';

class SupplierDialog {
  static void showSupplierDialog(
    BuildContext context,
    List<Map<String, dynamic>> listSupplier,
    Function(String) onSupplierAdded,
    Function(int, String) onSupplierEdited,
    Function(int) onSupplierDeleted,
    Function(String) onSupplierSelected,
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
                      'Pilih Supplier',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showTambahSupplierDialog(context, onSupplierAdded);
                      },
                      icon: const Icon(Icons.add, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: listSupplier.length,
                  itemBuilder: (context, index) {
                    final supplier = listSupplier[index];
                    return ListTile(
                      title: Text(supplier['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditSupplierDialog(
                            context,
                            supplier['id'],
                            supplier['name'],
                            onSupplierEdited,
                            onSupplierDeleted,
                          );
                        },
                      ),
                      onTap: () {
                        onSupplierSelected(supplier['name']);
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

  static void _showTambahSupplierDialog(
    BuildContext context,
    Function(String) onSupplierAdded,
  ) {
    final TextEditingController supplierBaruController =
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
                    controller: supplierBaruController,
                    decoration: InputDecoration(
                      labelText: 'Nama Supplier',
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
                    String newSupplier = supplierBaruController.text.trim();
                    if (newSupplier.isEmpty) {
                      setState(() {
                        errorMessage = 'Nama Supplier wajib diisi';
                      });
                    } else {
                      onSupplierAdded(newSupplier);
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

  static void _showEditSupplierDialog(
    BuildContext context,
    int id,
    String existingName,
    Function(int, String) onSupplierEdited,
    Function(int) onSupplierDeleted,
  ) {
    final TextEditingController supplierEditController =
        TextEditingController(text: existingName);
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Supplier'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: supplierEditController,
                    decoration: InputDecoration(
                      hintText: 'Nama Supplier',
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    onSupplierDeleted(id);
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
                    String updatedSupplier = supplierEditController.text.trim();
                    if (updatedSupplier.isEmpty) {
                      setState(() {
                        errorMessage = 'Supplier wajib diisi';
                      });
                    } else {
                      onSupplierEdited(id, updatedSupplier);
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

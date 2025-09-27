import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';

Future<void> showTambahProdukDialog(BuildContext context) async {
  Produk? selectedProduk;
  final TextEditingController jumlahController =
      TextEditingController(text: "0");
  final TextEditingController hargaController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Masukkan Produk yang Ingin Dibeli",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hanya dapat membeli produk yang tidak terhubung bahan baku.",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown Produk
                  DropdownSearch<Produk>(
                    items: (String? filter, _) async {
                      final list = await DatabaseHelper().getProduk();
                      if (filter != null && filter.isNotEmpty) {
                        return list
                            .where((p) => p.nama
                                .toLowerCase()
                                .contains(filter.toLowerCase()))
                            .toList();
                      }
                      return list;
                    },
                    selectedItem: selectedProduk,
                    itemAsString: (p) => p.nama,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "Pilih Produk",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Cari produk...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (produk) {
                      setState(() {
                        selectedProduk = produk;
                        jumlahController.text = "0";
                        hargaController.text =
                            (produk?.hargaJual ?? 0).toStringAsFixed(0);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Input jumlah, satuan, harga satuan (hanya jika produk dipilih)
                  if (selectedProduk != null) ...[
                    Row(
                      children: [
                        // Jumlah Unit
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: jumlahController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Jumlah Unit",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Satuan
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              selectedProduk?.satuanJual ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Harga Satuan
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: hargaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Harga Satuan",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tombol Tambah
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: selectedProduk == null
                          ? null
                          : () {
                              // TODO: Simpan data produk, jumlah, harga satuan
                              Navigator.pop(context);
                            },
                      child: Text(
                        "Tambah",
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

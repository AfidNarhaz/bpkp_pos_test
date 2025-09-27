import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:intl/intl.dart';

String formatRupiah(num number) {
  final formatter = NumberFormat('#,##0', 'id_ID');
  return formatter.format(number);
}

void showTambahProdukDialog(
  BuildContext context,
  Function(int id, String nama, int stok, String satuan, double harga)
      onProdukTambah,
) {
  Produk? selectedProduk;
  final TextEditingController jumlahController =
      TextEditingController(text: "0");
  final TextEditingController hargaController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Masukkan Produk yang Ingin Dibeli",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                            compareFn: (a, b) => a.id == b.id,
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
                              menuProps: MenuProps(),
                              constraints: BoxConstraints(maxHeight: 200),
                              fit: FlexFit.tight,
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
                          const SizedBox(height: 10),
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
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Jumlah unit tidak boleh kosong";
                                      }
                                      final intVal = int.tryParse(value);
                                      if (intVal == null || intVal <= 0) {
                                        return "Jumlah unit harus lebih dari 0";
                                      }
                                      return null;
                                    },
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
                                      hintText: formatRupiah(
                                        double.tryParse(hargaController.text
                                                .replaceAll('.', '')) ??
                                            0,
                                      ),
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Harga satuan tidak boleh kosong";
                                      }
                                      final doubleVal = double.tryParse(
                                          value.replaceAll('.', ''));
                                      if (doubleVal == null || doubleVal <= 0) {
                                        return "Harga satuan harus lebih dari 0";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      // Format angka saat input
                                      final raw = value.replaceAll('.', '');
                                      final numVal = int.tryParse(raw) ?? 0;
                                      final formatted = formatRupiah(numVal);
                                      if (value != formatted) {
                                        hargaController.value =
                                            TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(
                                              offset: formatted.length),
                                        );
                                      }
                                    },
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: selectedProduk == null
                                  ? null
                                  : () {
                                      if (formKey.currentState?.validate() ??
                                          false) {
                                        final id = selectedProduk!.id ?? 0;
                                        final stok = int.tryParse(
                                                jumlahController.text) ??
                                            0;
                                        // Hilangkan titik ribuan sebelum parsing
                                        final hargaText = hargaController.text
                                            .replaceAll('.', '');
                                        final harga =
                                            double.tryParse(hargaText) ?? 0.0;
                                        onProdukTambah(
                                          id,
                                          selectedProduk!.nama,
                                          stok,
                                          selectedProduk!.satuanJual ?? "",
                                          harga,
                                        );
                                        Navigator.pop(context);
                                      }
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

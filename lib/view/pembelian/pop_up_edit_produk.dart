import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/helper/format_rupiah.dart';

String formatRupiah(num number) {
  final formatter = NumberFormat('#,##0', 'id_ID');
  return formatter.format(number);
}

void showEditProdukDialog(
  BuildContext context,
  Map<String, dynamic> barang,
  Function(int stok, double harga) onUpdate,
) {
  final jumlahController = TextEditingController(
    text: barang['stok'].toString(),
  );
  final hargaController = TextEditingController(
    text: FormatRupiah(value: barang['harga_beli'])
        .formatted
        .replaceAll('Rp', '')
        .trim(),
  );

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ubah Produk yang Ingin Dibeli",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                barang['nama'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Jumlah Unit",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (value) {
                        final raw = value.replaceAll('.', '');
                        final numVal = int.tryParse(raw) ?? 0;
                        final formatted = formatRupiah(numVal);
                        if (value != formatted) {
                          jumlahController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        barang['satuan'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Harga Satuan",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: FormatRupiah(value: 1000000)
                            .formatted, // contoh hint
                      ),
                      onChanged: (value) {
                        final raw = value.replaceAll('.', '');
                        final numVal = int.tryParse(raw) ?? 0;
                        final formatted = formatRupiah(numVal);
                        if (value != formatted) {
                          hargaController.value = TextEditingValue(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final stok = int.tryParse(
                            jumlahController.text.replaceAll('.', '')) ??
                        barang['stok'];
                    final harga = double.tryParse(
                            hargaController.text.replaceAll('.', '')) ??
                        barang['harga_beli'];
                    onUpdate(stok, harga);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

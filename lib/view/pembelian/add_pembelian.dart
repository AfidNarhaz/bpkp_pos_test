import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/helper/format_rupiah.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/pembelian/pop_up_edit_produk.dart';
import 'package:bpkp_pos_test/view/pembelian/pop_up_supplier.dart';
import 'package:bpkp_pos_test/view/pembelian/pop_up_tambah_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_expired.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPembelian extends StatefulWidget {
  const AddPembelian({super.key});

  @override
  State<AddPembelian> createState() => _AddPembelianState();
}

class _AddPembelianState extends State<AddPembelian> {
  List<Map<String, dynamic>> barangs = [];

  String formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void insertBarang(
    int idBarang,
    String nama,
    int stok,
    String satuan,
    double hargaBeli,
  ) {
    Map<String, dynamic> barang = {
      'id_barang': idBarang,
      'nama': nama,
      'stok': stok,
      'satuan': satuan,
      'harga_beli': hargaBeli,
    };
    setState(() {
      barangs.add(barang);
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _tglPembelianController = TextEditingController();
  final TextEditingController _pilihSupplierController =
      TextEditingController();
  final TextEditingController _kodeKasController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _pembayaranController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refNoController.text = _generateRefNo();
    _tglPembelianController.text = _getTodayDate();
  }

  String _generateRefNo() {
    final now = DateTime.now();
    final tanggal =
        "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}";
    final random = now.millisecond.toString().padLeft(3, '0');
    return "R21-$tanggal$random";
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pembelian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Ref No
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _refNoController,
                    label: 'Ref No',
                  ),
                ),
                // Tanggal Pembelian
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _tglPembelianController,
                    label: 'Tanggal Pembelian',
                    suffixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () {
                      PopUpExpired.showPopUpExpired(
                        context,
                        (selectedDate) {
                          if (mounted) {
                            setState(() {
                              _tglPembelianController.text = selectedDate;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                // Pilih Suplier
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper()
                      .getSupplier(), // Pastikan ada fungsi getSupplier
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final supplierList = snapshot.data ?? [];
                    return SizedBox(
                      width: double.infinity,
                      child: _buildTextField(
                        controller: _pilihSupplierController,
                        label: 'Supplier',
                        suffixIcon: Icons.arrow_forward_ios,
                        readOnly: true,
                        onTap: () {
                          SupplierDialog.showSupplierDialog(
                            context,
                            supplierList,
                            (newSupplier) async {
                              if (newSupplier.isNotEmpty) {
                                await DatabaseHelper()
                                    .insertSupplier(newSupplier);
                                setState(() {});
                                _pilihSupplierController.text = newSupplier;
                              }
                            },
                            (id, updatedSupplier) async {
                              if (updatedSupplier.isNotEmpty) {
                                await DatabaseHelper()
                                    .updateSupplier(id, updatedSupplier);
                                setState(() {});
                              }
                            },
                            (id) async {
                              await DatabaseHelper().deleteSupplier(id);
                              setState(() {});
                            },
                            (selectedSupplier) {
                              setState(() {
                                _pilihSupplierController.text =
                                    selectedSupplier;
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                //Kode Kas
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _kodeKasController,
                    label: 'Kode Kas',
                  ),
                ),
                //Keterangan
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _keteranganController,
                    label: 'Keterangan',
                  ),
                ),
                //Pembayaran
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _pembayaranController,
                    label: 'Pembayaran',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Produk yang dibeli',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),

                // Tambah Produk
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      showTambahProdukDialog(
                        context,
                        (int id, String nama, int stok, String satuan,
                            double harga) {
                          insertBarang(id, nama, stok, satuan, harga);
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Tambah Produk',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Widget untuk menampilkan daftar produk yang sudah ditambahkan
                Column(
                  children: barangs.map((barang) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(barang['nama']),
                        subtitle: Row(
                          children: [
                            Text('${barang['stok']} ${barang['satuan']} @'),
                            FormatRupiah(value: barang['harga_beli']),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showEditProdukDialog(
                                  context,
                                  barang,
                                  (int stokBaru, double hargaBaru) {
                                    setState(() {
                                      barang['stok'] = stokBaru;
                                      barang['harga_beli'] = hargaBaru;
                                    });
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  barangs.remove(barang);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Simpan Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      List<Map<String, dynamic>> barangList = [
                        {'product_id': 1},
                        {'product_id': 2},
                        {'product_id': 3},
                      ];

                      String supplier = 'Supplier A';

                      await DatabaseHelper()
                          .insertPembelian(barangList, supplier);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatter,
    Function()? onTap,
    Function()? onSuffixIconTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        inputFormatters: inputFormatter,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixIconTap,
                  child: Icon(suffixIcon),
                )
              : null,
          filled: true,
          fillColor: Colors.blue[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}

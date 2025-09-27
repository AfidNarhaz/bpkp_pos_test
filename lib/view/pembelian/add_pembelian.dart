import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/pembelian/pop_up_edit_produk.dart';
import 'package:bpkp_pos_test/view/pembelian/pop_up_tambah_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_expired.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_kategori.dart';
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
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _kodeProdukController = TextEditingController();
  final TextEditingController _tglPembelianController = TextEditingController();

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
                    controller: _kodeProdukController,
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
                  future: DatabaseHelper().getKategori(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final kategoriList = snapshot.data ?? [];
                    return SizedBox(
                      width: double.infinity,
                      child: _buildTextField(
                        controller: _kategoriController,
                        label: 'Supplier',
                        suffixIcon: Icons.arrow_forward_ios,
                        readOnly: true,
                        onTap: () {
                          KategoriDialog.showKategoriDialog(
                            context,
                            kategoriList,
                            (newKategori) async {
                              if (newKategori.isNotEmpty) {
                                await DatabaseHelper()
                                    .insertKategori(newKategori);
                                setState(() {});
                                _kategoriController.text = newKategori;
                              }
                            },
                            (id, updatedKategori) async {
                              if (updatedKategori.isNotEmpty) {
                                await DatabaseHelper()
                                    .updateKategori(id, updatedKategori);
                                setState(() {});
                              }
                            },
                            (id) async {
                              await DatabaseHelper().deleteKategori(id);
                              setState(() {});
                            },
                            (selectedKategori) {
                              setState(() {
                                _kategoriController.text = selectedKategori;
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
                    controller: _kodeProdukController,
                    label: 'Kode Kas',
                  ),
                ),
                //Keterangan
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _kodeProdukController,
                    label: 'Keterangan',
                  ),
                ),
                //Pembayaran
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField(
                    controller: _kodeProdukController,
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
                        subtitle: Text(
                          '${barang['stok']} ${barang['satuan']} @Rp${formatRupiah(barang['harga_beli'])}',
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

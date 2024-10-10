import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/kelola_produk/pop_up_kategori.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TambahProdukPage extends StatefulWidget {
  final Product? produk;
  const TambahProdukPage({super.key, this.produk});

  @override
  TambahProdukPageState createState() => TambahProdukPageState();
}

class TambahProdukPageState extends State<TambahProdukPage> {
  List<Map<String, dynamic>> _listKategori = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() async {
    List<Map<String, dynamic>> kategoriList =
        await DatabaseHelper().getKategori();
    setState(() {
      _listKategori = kategoriList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Tambahkan logika untuk mengambil gambar
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nama Produk
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Produk',
                ),

                // Pilih Kategori
                _buildTextField(
                  controller: _kategoriController,
                  label: 'Pilih Kategori',
                  suffixIcon: Icons.arrow_forward_ios,
                  readOnly: true,
                  onTap: () {
                    KategoriDialog.showKategoriDialog(
                      context,
                      _listKategori,
                      (newKategori) async {
                        if (newKategori.isNotEmpty) {
                          await DatabaseHelper().insertKategori(newKategori);
                          _loadKategori();
                        }
                      },
                      (id, updatedKategori) async {
                        if (updatedKategori.isNotEmpty) {
                          await DatabaseHelper()
                              .updateKategori(id, updatedKategori);
                          _loadKategori();
                        }
                      },
                      (id) async {
                        await DatabaseHelper().deleteKategori(id);
                        _loadKategori();
                      },
                      (selectedKategori) {
                        setState(() {
                          _kategoriController.text = selectedKategori;
                        });
                      },
                    );
                  },
                ),

                // Pilih Merek
                _buildTextField(
                  controller: _merekController,
                  label: 'Pilih Merek',
                  suffixIcon: Icons.arrow_forward_ios,
                  readOnly: true,
                  onTap: () {
                    // Logika untuk memilih merek
                  },
                ),

                // Kode Produk / Barcode
                _buildTextField(
                  controller: _kodeController,
                  label: 'Kode Produk/Barcode',
                  suffixIcon: Icons.qr_code_scanner,
                  onTap: () {
                    // Logika untuk memindai kode barcode
                  },
                ),

                // Harga Modal
                _buildTextField(
                  controller: _hargaModalController,
                  label: 'Harga Modal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                ),

                // Tanggal Kadaluwarsa
                _buildTextField(
                  controller: _tanggalController,
                  label: 'Tanggal Kadaluwarsa',
                  suffixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () {
                    // Logika untuk memilih tanggal
                  },
                ),

                // Harga Jual
                _buildTextField(
                  controller: _hargaJualController,
                  label: 'Harga Jual',
                  keyboardType: TextInputType.number,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                ),

                // Jadikan Favorit Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadikan favorit?',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: isFavorite,
                      onChanged: (value) {
                        setState(() {
                          isFavorite = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tombol Simpan
                OutlinedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logika untuk menyimpan produk
                    }
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun TextFormField dengan ikon opsional
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatter,
    Function()? onTap,
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
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
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

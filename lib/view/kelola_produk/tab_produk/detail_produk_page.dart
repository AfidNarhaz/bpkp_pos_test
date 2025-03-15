import 'dart:io';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/barcode_scanner_page.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_kategori.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_merek.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_expired.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'image_service.dart'; // Import image_service

class DetailProdukPage extends StatefulWidget {
  final Product produk;

  const DetailProdukPage({super.key, required this.produk});

  @override
  DetailProdukPageState createState() => DetailProdukPageState();
}

class DetailProdukPageState extends State<DetailProdukPage> {
  List<Map<String, dynamic>> _listKategori = [];
  List<Map<String, dynamic>> _listMerek = [];
  final _formKey = GlobalKey<FormState>();

  // Kontrol gambar dan service image
  File? _image;
  final ImageService _imageService = ImageService();

  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _merekController;
  late TextEditingController _kodeController;
  late TextEditingController _hargaModalController;
  late TextEditingController _hargaJualController;
  late TextEditingController _tanggalKadaluwarsaController;

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _imageService.initDb(); // Inisialisasi database gambar
    _loadKategori();
    _loadMerek();

    // Inisialisasi dengan nilai produk yang ada
    _namaController = TextEditingController(text: widget.produk.nama);
    _kategoriController = TextEditingController(text: widget.produk.kategori);
    _merekController = TextEditingController(text: widget.produk.merek);
    _kodeController = TextEditingController(text: widget.produk.kode);
    _hargaModalController = TextEditingController(
        text: NumberFormat('#,###', 'en_US')
            .format(widget.produk.hargaModal)
            .replaceAll(',', '.'));
    _hargaJualController = TextEditingController(
        text: NumberFormat('#,###', 'en_US')
            .format(widget.produk.hargaJual)
            .replaceAll(',', '.'));
    _tanggalKadaluwarsaController =
        TextEditingController(text: widget.produk.tanggalKadaluwarsa);
    isFavorite = widget.produk.isFavorite;
    if (widget.produk.imagePath != null) {
      _image = File(widget.produk.imagePath!);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _merekController.dispose();
    _kodeController.dispose();
    _hargaModalController.dispose();
    _hargaJualController.dispose();
    _tanggalKadaluwarsaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imageService.pickAndSaveImage(); // Ambil gambar
    if (image != null) {
      setState(() {
        _image = image; // Update nilai _image dan render ulang UI
      });
    }
  }

  void _loadKategori() async {
    List<Map<String, dynamic>> kategoriList =
        await DatabaseHelper().getKategori();
    setState(() {
      _listKategori = kategoriList;
    });
  }

  void _loadMerek() async {
    List<Map<String, dynamic>> merekList = await DatabaseHelper().getMerek();
    setState(() {
      _listMerek = merekList;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Perbarui objek produk dengan nilai baru
      Product updatedProduct = Product(
        id: widget.produk.id,
        nama: _namaController.text,
        kategori: _kategoriController.text,
        merek: _merekController.text,
        kode: _kodeController.text,
        hargaModal:
            double.tryParse(_hargaModalController.text.replaceAll('.', '')) ??
                0.0,
        hargaJual:
            double.tryParse(_hargaJualController.text.replaceAll('.', '')) ??
                0.0,
        tanggalKadaluwarsa: _tanggalKadaluwarsaController.text,
        isFavorite: isFavorite,
        imagePath: _image?.path ?? widget.produk.imagePath,
      );

      Navigator.pop(
          context, updatedProduct); // Kembali dengan produk yang diperbarui
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //Gambar Produk
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : (widget.produk.imagePath != null
                              ? DecorationImage(
                                  image:
                                      FileImage(File(widget.produk.imagePath!)),
                                  fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_image == null && widget.produk.imagePath == null)
                        ? const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.black54,
                          )
                        : null,
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
                  onTap: () async {
                    MerekDialog.showMerekDialog(
                      context,
                      _listMerek,
                      (newMerek) async {
                        if (newMerek.isNotEmpty) {
                          await DatabaseHelper().insertMerek(newMerek);
                          _loadMerek();
                        }
                      },
                      (id, updatedMerek) async {
                        if (updatedMerek.isNotEmpty) {
                          await DatabaseHelper().updateMerek(id, updatedMerek);
                          _loadMerek();
                        }
                      },
                      (id) async {
                        await DatabaseHelper().deleteMerek(id);
                        _loadMerek();
                      },
                      (selectedMerek) {
                        setState(() {
                          _merekController.text = selectedMerek;
                        });
                      },
                    );
                  },
                ),

                // Harga Jual
                _buildTextField(
                  controller: _hargaJualController,
                  label: 'Harga Jual',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),

                // Harga Modal
                _buildTextField(
                  controller: _hargaModalController,
                  label: 'Harga Modal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),

                // Kode Produk / Barcode
                _buildTextField(
                  controller: _kodeController,
                  label: 'Kode Produk/Barcode',
                  suffixIcon: Icons.barcode_reader,
                  onTap: () async {
                    final barcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeScannerPage(
                          onBarcodeScanned: (barcode) {
                            Navigator.pop(context, barcode);
                          },
                        ),
                      ),
                    );

                    if (barcode != null && barcode.isNotEmpty) {
                      setState(() {
                        _kodeController.text = barcode;
                      });
                    }
                  },
                ),

                // Tanggal Kadaluwarsa
                _buildTextField(
                  controller: _tanggalKadaluwarsaController,
                  label: 'Tanggal Kadaluwarsa',
                  suffixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () {
                    PopUpExpired.showPopUpExpired(
                      context,
                      (selectedDate) {
                        setState(() {
                          _tanggalKadaluwarsaController.text = selectedDate;
                        });
                      },
                    );
                  },
                ),

                // Jadikan Favorit Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jadikan favorit?',
                        style: TextStyle(fontSize: 16)),
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
                  onPressed: _saveChanges,
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
                )
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
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: () async {
                    if (label == 'Kode Produk/Barcode') {
                      final barcode = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BarcodeScannerPage(
                            onBarcodeScanned: (barcode) {
                              Navigator.pop(context, barcode);
                            },
                          ),
                        ),
                      );

                      if (barcode != null && barcode.isNotEmpty) {
                        setState(() {
                          controller.text = barcode;
                        });
                      }
                    } else if (onTap != null) {
                      onTap();
                    }
                  },
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

// Formatter untuk menambahkan pemisah ribuan (menggunakan titik)
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final newText = newValue.text.replaceAll('.', '').replaceAll(',', '');
    final number = int.parse(newText);
    final newString = formatter.format(number).replaceAll(',', '.');

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_kategori.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_expired.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/pop_up_merek.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/pop_up_satuan.dart';
import 'package:bpkp_pos_test/view/kelola_produk/barcode_scanner_page.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'image_service.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class AddProdukPage extends StatefulWidget {
  const AddProdukPage({super.key, this.produk, required this.onProdukAdded});
  final Produk? produk;
  final VoidCallback onProdukAdded;

  @override
  AddProdukPageState createState() => AddProdukPageState();
}

class AddProdukPageState extends State<AddProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();

  bool isFavorite = false;
  bool _sendNotification = false;

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _merekController.dispose();
    _barcodeController.dispose();
    _hargaModalController.dispose();
    _hargaJualController.dispose();
    _tanggalController.dispose();
    _stokController.dispose();
    _minStokController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imageService.initDb();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        // Salin gambar ke folder aplikasi
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'produk_${DateTime.now().millisecondsSinceEpoch}${extension(pickedFile.path)}';
        final savedImage =
            await File(pickedFile.path).copy(join(appDir.path, fileName));
        if (mounted) {
          setState(() {
            _image = savedImage; // path sudah di folder aplikasi
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Failed to pick an image: $e')),
        );
      }
    }
  }

  Future<void> _saveProduk() async {
    if (_formKey.currentState!.validate()) {
      final newProduk = Produk(
        imagePath: _image?.path,
        nama: _namaController.text,
        kategori: _kategoriController.text,
        merek: _merekController.text,
        hargaJual:
            double.tryParse(_hargaJualController.text.replaceAll('.', '')) ??
                0.0,
        hargaModal:
            double.tryParse(_hargaModalController.text.replaceAll('.', '')) ??
                0.0,
        barcode: _barcodeController.text,
        tglExpired: _tanggalController.text,
        stok: int.tryParse(_stokController.text.replaceAll('.', '')) ?? 0,
        minStok: int.tryParse(_minStokController.text.replaceAll('.', '')) ?? 0,
        satuan: _satuanController.text,
        isFavorite: isFavorite,
        sendNotification: _sendNotification,
      );
      await DatabaseHelper().insertProduk(newProduk);
      if (mounted) {
        widget.onProdukAdded();
        Navigator.pop(this.context, newProduk);
      }
      if (_sendNotification &&
          newProduk.stok != null &&
          newProduk.minStok != null &&
          newProduk.stok! <= newProduk.minStok!) {
        _sendStockNotification(newProduk);
      }
    }
  }

  void _sendStockNotification(Produk produk) {
    debugPrint("[INFO] Sending notification for product: ${produk.nama}");
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
                  onTap: () async {
                    await _pickImage();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _image == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: Colors.black54,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Produk',
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getKategori(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final kategoriList = snapshot.data ?? [];
                    return _buildTextField(
                      controller: _kategoriController,
                      label: 'Pilih Kategori',
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
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getMerek(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final merekList = snapshot.data ?? [];
                    return _buildTextField(
                      controller: _merekController,
                      label: 'Pilih Merek',
                      suffixIcon: Icons.arrow_forward_ios,
                      readOnly: true,
                      onTap: () {
                        MerekDialog.showMerekDialog(
                          context,
                          merekList,
                          (newMerek) async {
                            if (newMerek.isNotEmpty) {
                              await DatabaseHelper().insertMerek(newMerek);
                              setState(() {});
                              _merekController.text = newMerek;
                            }
                          },
                          (id, updatedMerek) async {
                            if (updatedMerek.isNotEmpty) {
                              await DatabaseHelper()
                                  .updateMerek(id, updatedMerek);
                              setState(() {});
                            }
                          },
                          (id) async {
                            await DatabaseHelper().deleteMerek(id);
                            setState(() {});
                          },
                          (selectedMerek) {
                            setState(() {
                              _merekController.text = selectedMerek;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
                _buildTextField(
                  controller: _hargaJualController,
                  label: 'Harga Jual',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                _buildTextField(
                  controller: _hargaModalController,
                  label: 'Harga Modal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                _buildTextField(
                  controller: _barcodeController,
                  label: 'Barcode',
                  suffixIcon: Icons.barcode_reader,
                  onSuffixIconTap: () async {
                    final barcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerPage(),
                      ),
                    );
                    if (barcode != null && barcode.isNotEmpty && mounted) {
                      setState(() {
                        _barcodeController.text = barcode;
                      });
                    }
                  },
                ),
                _buildTextField(
                  controller: _tanggalController,
                  label: 'Tanggal Kadaluwarsa',
                  suffixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () {
                    PopUpExpired.showPopUpExpired(
                      context,
                      (selectedDate) {
                        if (mounted) {
                          setState(() {
                            _tanggalController.text = selectedDate;
                          });
                        }
                      },
                    );
                  },
                ),
                _buildTextField(
                  controller: _stokController,
                  label: 'Stok Produk',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                _buildTextField(
                  controller: _minStokController,
                  label: 'Stok Minimal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getSatuan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final satuanList = snapshot.data ?? [];
                    return _buildTextField(
                      controller: _satuanController,
                      label: 'Pilih Satuan',
                      suffixIcon: Icons.arrow_forward_ios,
                      readOnly: true,
                      onTap: () {
                        SatuanDialog.showSatuanDialog(
                          context,
                          satuanList,
                          (newSatuan) async {
                            if (newSatuan.isNotEmpty) {
                              await DatabaseHelper().insertSatuan(newSatuan);
                              setState(() {});
                              _satuanController.text = newSatuan;
                            }
                          },
                          (id, updatedSatuan) async {
                            if (updatedSatuan.isNotEmpty) {
                              await DatabaseHelper()
                                  .updateSatuan(id, updatedSatuan);
                              setState(() {});
                            }
                          },
                          (id) async {
                            await DatabaseHelper().deleteSatuan(id);
                            setState(() {});
                          },
                          (selectedSatuan) {
                            setState(() {
                              _satuanController.text = selectedSatuan;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _sendNotification,
                      onChanged: (bool? value) {
                        setState(() {
                          _sendNotification = value ?? false;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),
                    Expanded(
                      child: const Text(
                        'Kirimkan notifikasi saat stok mencapai batas minimum',
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jadikan favorit?',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: isFavorite,
                      activeColor: AppColors.favorit,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            isFavorite = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _saveProduk,
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
    final number = int.tryParse(newText) ?? 0;
    final newString = formatter.format(number).replaceAll(',', '.');
    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

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
import 'image_service.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/pop_up_satuan.dart';

class DetailProdukPage extends StatefulWidget {
  final Produk produk;
  const DetailProdukPage({super.key, required this.produk});

  @override
  DetailProdukPageState createState() => DetailProdukPageState();
}

class DetailProdukPageState extends State<DetailProdukPage> {
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
  late TextEditingController _tanggalController;
  late TextEditingController _stokController;
  late TextEditingController _minStokController;
  late TextEditingController _satuanController;

  bool isFavorite = false;
  bool _sendNotification = false;

  String? stok;
  String? minStok;
  String? satuan;

  @override
  void initState() {
    super.initState();
    _imageService.initDb(); // Inisialisasi database gambar
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
    _tanggalController = TextEditingController(text: widget.produk.tglExpired);
    _satuanController = TextEditingController(text: widget.produk.satuan);
    _stokController =
        TextEditingController(text: widget.produk.stok?.toString());
    _minStokController =
        TextEditingController(text: widget.produk.minStok?.toString());
    isFavorite = widget.produk.isFavorite;
    if (widget.produk.imagePath != null) {
      _image = File(widget.produk.imagePath!);
    }
    stok = widget.produk.stok?.toString();
    minStok = widget.produk.minStok?.toString();
    satuan = widget.produk.satuan;
    _sendNotification = widget.produk.sendNotification ?? false;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _merekController.dispose();
    _kodeController.dispose();
    _hargaModalController.dispose();
    _hargaJualController.dispose();
    _tanggalController.dispose();
    _stokController.dispose(); // Dispose _stokController
    _minStokController.dispose(); // Dispose _minStokController
    _satuanController.dispose(); // Dispose _satuanController
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imageService.pickAndSaveImage(); // Ambil gambar
    if (image != null) {
      if (!mounted) return;
      setState(() {
        _image = image; // Update nilai _image dan render ulang UI
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Perbarui objek produk dengan nilai baru
      Produk updatedProduct = Produk(
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
        tglExpired: _tanggalController.text,
        isFavorite: isFavorite,
        imagePath: _image?.path ?? widget.produk.imagePath,
        stok: int.tryParse(_stokController.text.replaceAll('.', '')) ??
            0, // Use _stokController
        minStok: int.tryParse(_minStokController.text.replaceAll('.', '')) ??
            0, // Use _minStokController
        satuan: _satuanController.text, // Use _satuanController
        sendNotification: _sendNotification, // Include sendNotification
      );

      await DatabaseHelper()
          .updateProduk(updatedProduct); // Save changes to database

      _checkStockAndNotify();

      if (mounted) {
        Navigator.pop(
            context, updatedProduct); // Kembali dengan produk yang diperbarui
      }
    }
  }

  void _checkStockAndNotify() {
    if (_sendNotification && stok != null && minStok != null) {
      int currentStock = int.tryParse(stok!) ?? 0;
      int minimumStock = int.tryParse(minStok!) ?? 0;
      if (currentStock <= minimumStock) {
        // Logic to send notification
        // This is a placeholder for actual notification logic
        debugPrint(
            "Sending notification: Stock has reached the minimum limit.");
      }
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

                // Pilih Merek
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
                            if (!mounted) return;
                            Navigator.pop(context, barcode);
                          },
                        ),
                      ),
                    );

                    if (barcode != null && barcode.isNotEmpty) {
                      if (!mounted) return;
                      setState(() {
                        _kodeController.text = barcode;
                      });
                    }
                  },
                ),

                // Tanggal Kadaluwarsa
                _buildTextField(
                  controller: _tanggalController,
                  label: 'Tanggal Kadaluwarsa',
                  suffixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () {
                    PopUpExpired.showPopUpExpired(
                      context,
                      (selectedDate) {
                        if (!mounted) return;
                        setState(() {
                          _tanggalController.text = selectedDate;
                        });
                      },
                    );
                  },
                ),

                //Stok Produk
                _buildTextField(
                  controller: _stokController,
                  label: 'Stok Produk',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),

                //Stok Minimal
                _buildTextField(
                  controller: _minStokController,
                  label: 'Stok Minimal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),

                // Pilih Satuan
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

                // Checkbox for notification
                Row(
                  children: [
                    Checkbox(
                      value: _sendNotification,
                      onChanged: (bool? value) {
                        setState(() {
                          _sendNotification = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: const Text(
                        'Kirimkan notifikasi saat stok mencapai batas minimum',
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
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
                        if (!mounted) return;
                        setState(() {
                          isFavorite = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Hapus dan Simpan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Hapus
                    OutlinedButton(
                      onPressed: () async {
                        // Logika hapus produk
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Apakah Anda yakin ingin menghapus produk ini?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Tutup dialog
                                  },
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (widget.produk.id != null) {
                                      await DatabaseHelper()
                                          .deleteProduk(widget.produk.id!);
                                      if (!mounted) return;
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .pop(); // Tutup dialog
                                        Navigator.pop(context,
                                            'deleted'); // Kembali ke halaman sebelumnya
                                      }
                                    }
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        minimumSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Tombol Simpan
                    OutlinedButton(
                      onPressed: _saveChanges,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                              if (!mounted) return;
                              Navigator.pop(context, barcode);
                            },
                          ),
                        ),
                      );

                      if (barcode != null && barcode.isNotEmpty) {
                        if (!mounted) return;
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

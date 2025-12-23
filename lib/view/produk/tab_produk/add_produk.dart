import 'package:bpkp_pos_test/model/model_history_produk.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_kategori.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_expired.dart';
import 'package:bpkp_pos_test/view/produk/tab_produk/pop_up_merek.dart';
import 'package:bpkp_pos_test/view/produk/widget/pop_up_satuan.dart';
import 'package:bpkp_pos_test/view/produk/widget/barcode_scanner.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'image_service.dart';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

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
  File? _image;

  final TextEditingController _kodeProdukController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _satuanUnitController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();

  final bool _sendNotification = false;
  String? _kodeProdukError;

  @override
  void dispose() {
    _kodeProdukController.dispose();
    _barcodeController.dispose();
    _namaController.dispose();
    _kategoriController.dispose();
    _merekController.dispose();
    _tanggalController.dispose();
    _satuanUnitController.dispose();
    _hargaJualController.dispose();
    _minStokController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imageService.initDb();
    _generateNextKodeProdukg();
    _kodeProdukController.addListener(_validateKodeProduk);
  }

  Future<void> _generateNextKodeProdukg() async {
    try {
      final allProduk = await DatabaseHelper().getProduk();
      final existingCodes =
          allProduk.map((p) => p.codeProduk.toUpperCase()).toSet();

      String randomCode;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      // Generate random kode sampai menemukan yang unik
      do {
        randomCode = _generateRandomCode();
        isUnique = !existingCodes.contains(randomCode.toUpperCase());
        attempts++;
      } while (!isUnique && attempts < maxAttempts);

      if (!isUnique) {
        // Fallback jika gagal generate unique code
        debugPrint(
            'Failed to generate unique code after $maxAttempts attempts');
        randomCode =
            'PRD${Random().nextInt(1000000).toString().padLeft(6, '0')}';
      }

      if (mounted) {
        setState(() {
          _kodeProdukController.text = randomCode;
          _kodeProdukError = null;
        });
      }
    } catch (e) {
      debugPrint('Error generating kode produk: $e');
    }
  }

  String _generateRandomCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    String randomPart = '';

    for (int i = 0; i < 6; i++) {
      randomPart += chars[random.nextInt(chars.length)];
    }

    return 'PRD$randomPart';
  }

  Future<void> _validateKodeProduk() async {
    final kodeInput = _kodeProdukController.text.trim();

    if (kodeInput.isEmpty) {
      setState(() {
        _kodeProdukError = null;
      });
      return;
    }

    try {
      final allProduk = await DatabaseHelper().getProduk();
      final isDuplicate = allProduk.any((produk) =>
          produk.codeProduk.toLowerCase() == kodeInput.toLowerCase());

      if (mounted) {
        setState(() {
          if (isDuplicate) {
            _kodeProdukError =
                'Kode produk "$kodeInput" sudah digunakan. Gunakan kode produk yang berbeda.';
          } else {
            _kodeProdukError = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error validating kode produk: $e');
    }
  }

  Future<void> _saveProduk() async {
    if (_kodeProdukError != null && _kodeProdukError!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_kodeProdukError!),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newProduk = Produk(
        imagePath: _image?.path,
        codeProduk: _kodeProdukController.text,
        barcode: _barcodeController.text,
        nama: _namaController.text,
        kategori: _kategoriController.text,
        merek: _merekController.text,
        tglExpired: _tanggalController.text.isNotEmpty
            ? _tanggalController.text
            : DateFormat('dd-MM-yyyy').format(DateTime.now()),
        satuanUnit: _satuanUnitController.text,
        hargaBeli: 0.0,
        hargaJual:
            double.tryParse(_hargaJualController.text.replaceAll('.', '')) ??
                0.0,
        minStok: int.tryParse(_minStokController.text.replaceAll('.', '')) ?? 0,
        stok: 0, // Set stok selalu 0
        sendNotification: _sendNotification,
      );
      await DatabaseHelper().insertProduk(newProduk);

      final username = await getCurrentUsername();
      final role = await getCurrentUserRole();
      await DatabaseHelper().insertHistoryProduk(
        HistoryProduk(
          aksi: 'Tambah Produk',
          namaProduk: newProduk.nama,
          user: username ?? 'Unknown',
          role: role ?? 'Unknown',
          waktu: DateTime.now(),
          detail: 'Produk baru ditambahkan',
        ),
      );
      if (mounted) {
        widget.onProdukAdded();
        Navigator.pop(context, newProduk);
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
                // Gambar Produk
                GestureDetector(
                  onTap: () async {
                    final image = await _pickImageWithSource(context);
                    if (image != null && mounted) {
                      setState(() {
                        _image = image;
                      });
                    }
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
                const SizedBox(height: 10),
                // Kode Produk
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _kodeProdukController,
                      label: 'Kode Produk',
                    ),
                    if (_kodeProdukError != null &&
                        _kodeProdukError!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 4.0, right: 16.0),
                        child: Text(
                          _kodeProdukError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                // Barcode
                _buildTextField(
                  controller: _barcodeController,
                  label: 'Barcode',
                  suffixIcon: Icons.barcode_reader,
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  isRequired: false,
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
                        if (mounted) {
                          setState(() {
                            _tanggalController.text = selectedDate;
                          });
                        }
                      },
                    );
                  },
                ),

                // Pilih Satuan unit
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getSatuan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final satuanUnitList = snapshot.data ?? [];
                    return _buildTextField(
                      controller: _satuanUnitController,
                      label: 'Pilih Satuan Unit',
                      suffixIcon: Icons.arrow_forward_ios,
                      readOnly: true,
                      onTap: () {
                        SatuanDialog.showSatuanDialog(
                          context,
                          satuanUnitList,
                          (newSatuanUnit) async {
                            if (newSatuanUnit.isNotEmpty) {
                              await DatabaseHelper()
                                  .insertSatuan(newSatuanUnit);
                              setState(() {});
                              _satuanUnitController.text = newSatuanUnit;
                            }
                          },
                          (id, updatedSatuanUnit) async {
                            if (updatedSatuanUnit.isNotEmpty) {
                              await DatabaseHelper()
                                  .updateSatuan(id, updatedSatuanUnit);
                              setState(() {});
                            }
                          },
                          (id) async {
                            await DatabaseHelper().deleteSatuan(id);
                            setState(() {});
                          },
                          (selectedSatuanUnit) {
                            setState(() {
                              _satuanUnitController.text = selectedSatuanUnit;
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
                // Stok Minimal
                _buildTextField(
                  controller: _minStokController,
                  label: 'Stok Minimal',
                  keyboardType: TextInputType.number,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                const SizedBox(height: 10),
                // Tombol Simpan
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
    bool isRequired = true,
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
          if (isRequired && (value == null || value.isEmpty)) {
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

// Fungsi untuk ambil username user yang sedang login
Future<String?> getCurrentUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

// Fungsi untuk ambil role user yang sedang login
Future<String?> getCurrentUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

// Fungsi untuk memilih sumber gambar
Future<File?> _pickImageWithSource(BuildContext context) async {
  final picker = ImagePicker();
  File? imageFile;

  await showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Kamera'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.camera);
              if (picked != null) imageFile = File(picked.path);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () async {
              final picked =
                  await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) imageFile = File(picked.path);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
  return imageFile;
}

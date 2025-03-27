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
import 'package:image_picker/image_picker.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/pop_up_satuan.dart';

class AddProdukPage extends StatefulWidget {
  const AddProdukPage({super.key, this.produk, required this.onProdukAdded});
  final Produk? produk;
  final VoidCallback onProdukAdded;

  @override
  AddProdukPageState createState() => AddProdukPageState();
}

class AddProdukPageState extends State<AddProdukPage> {
  List<Map<String, dynamic>> _listKategori = [];
  List<Map<String, dynamic>> _listMerek = [];
  List<Map<String, dynamic>> _listSatuan = [];

  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _hargaModalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();

  bool isFavorite = false;
  bool _sendNotification = false;

  String? stok;
  String? minStok;
  String? satuan;

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _merekController.dispose();
    _kodeController.dispose();
    _hargaModalController.dispose();
    _hargaJualController.dispose();
    _tanggalController.dispose();
    _stokController.dispose();
    _minStokController.dispose();
    _satuanController.dispose();
    super.dispose();
  } // Panggil method dispose dari parent class

  @override
  void initState() {
    super.initState();
    _imageService.initDb(); // Inisialisasi database gambar
    _initializeServices(); // Inisialisasi service
    _loadKategori(); // Memuat kategori dari database
    _loadMerek(); // Memuat merek dari database
    _loadSatuan(); // Memuat satuan dari database
  }

  Future<void> _initializeServices() async {
    try {
      debugPrint("[INFO] Initializing ImageService and loading data...");
      await _imageService.initDb();
      await _loadKategori();
      await _loadMerek();
      debugPrint("[INFO] Initialization completed successfully.");
    } catch (e) {
      debugPrint("[ERROR] Failed to initialize services: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      debugPrint("[INFO] Attempting to pick an image...");
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final image = File(pickedFile.path);
        if (mounted) {
          setState(() {
            _image = image;
          });
          debugPrint("[INFO] Image picked and set successfully: ${image.path}");
        }
      } else {
        debugPrint("[WARNING] No image was picked.");
      }
    } on PlatformException catch (e) {
      debugPrint(
          "[ERROR] PlatformException while picking an image: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick an image: ${e.message}')),
        );
      }
    } on FileSystemException catch (e) {
      debugPrint(
          "[ERROR] FileSystemException while picking an image: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save the image: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint("[ERROR] Unexpected error while picking an image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _loadKategori() async {
    try {
      debugPrint("[INFO] Loading categories...");
      List<Map<String, dynamic>> kategoriList =
          await DatabaseHelper().getKategori();
      if (!mounted) return;
      setState(() {
        _listKategori = kategoriList;
      });
      debugPrint("[INFO] Loaded ${_listKategori.length} categories.");
    } catch (e) {
      debugPrint("[ERROR] Error loading categories: $e");
    }
  }

  Future<void> _loadMerek() async {
    try {
      debugPrint("[INFO] Loading merek...");
      List<Map<String, dynamic>> merekList = await DatabaseHelper().getMerek();
      if (!mounted) return;
      setState(() {
        _listMerek = merekList;
      });
      debugPrint("[INFO] Loaded ${_listMerek.length} merek.");
    } catch (e) {
      debugPrint("[ERROR] Error loading merek: $e");
    }
  }

  Future<void> _loadSatuan() async {
    try {
      debugPrint("[INFO] Loading satuan...");
      List<Map<String, dynamic>> satuanList =
          await DatabaseHelper().getSatuan();
      if (!mounted) return;
      setState(() {
        _listSatuan = satuanList;
      });
      debugPrint("[INFO] Loaded ${_listSatuan.length} satuan.");
    } catch (e) {
      debugPrint("[ERROR] Error loading satuan: $e");
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
        kode: _kodeController.text,
        tanggalKadaluwarsa: _tanggalController.text,
        stok: int.tryParse(_stokController.text.replaceAll('.', '')) ?? 0,
        minStok: int.tryParse(_minStokController.text.replaceAll('.', '')) ?? 0,
        satuan: _satuanController.text,
        isFavorite: isFavorite,
        sendNotification: _sendNotification, // Include sendNotification
      );
      await DatabaseHelper()
          .insertProduk(newProduk); // Simpan produk ke database
      if (mounted) {
        widget.onProdukAdded(); // Panggil callback onProdukAdded
        Navigator.pop(context,
            newProduk); // Kembali ke halaman sebelumnya dengan membawa data produk
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
    // Implement the logic to send a notification
    // This is a placeholder for the actual notification logic
    debugPrint("[INFO] Sending notification for product: ${produk.nama}");
    // Use a package like flutter_local_notifications to send the notification
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
                    await _pickImage(); // Panggil fungsi _pickImage saat gambar ditekan
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
                          if (mounted) {
                            _loadKategori();
                            setState(() {
                              _kategoriController.text =
                                  newKategori; // Set the text field value immediately
                            });
                          }
                        }
                      },
                      (id, updatedKategori) async {
                        if (updatedKategori.isNotEmpty) {
                          await DatabaseHelper()
                              .updateKategori(id, updatedKategori);
                          if (mounted) {
                            _loadKategori();
                          }
                        }
                      },
                      (id) async {
                        await DatabaseHelper().deleteKategori(id);
                        if (mounted) {
                          _loadKategori();
                        }
                      },
                      (selectedKategori) {
                        if (mounted) {
                          setState(() {
                            _kategoriController.text = selectedKategori;
                          });
                        }
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
                          if (mounted) {
                            _loadMerek();
                            setState(() {
                              _merekController.text =
                                  newMerek; // Set the text field value immediately
                            });
                          }
                        }
                      },
                      (id, updatedMerek) async {
                        if (updatedMerek.isNotEmpty) {
                          await DatabaseHelper().updateMerek(id, updatedMerek);
                          if (mounted) {
                            _loadMerek();
                          }
                        }
                      },
                      (id) async {
                        await DatabaseHelper().deleteMerek(id);
                        if (mounted) {
                          _loadMerek();
                        }
                      },
                      (selectedMerek) {
                        if (mounted) {
                          setState(() {
                            _merekController.text = selectedMerek;
                          });
                        }
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
                  onSuffixIconTap: () async {
                    final barcode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeScannerPage(
                          onBarcodeScanned: (barcode) {
                            if (mounted) {
                              Navigator.pop(context, barcode);
                            }
                          },
                        ),
                      ),
                    );

                    if (barcode != null && barcode.isNotEmpty && mounted) {
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
                        if (mounted) {
                          setState(() {
                            _tanggalController.text =
                                selectedDate; // Mengisi field dengan tanggal yang dipilih
                          });
                        }
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
                _buildTextField(
                  controller: _satuanController,
                  label: 'Pilih Satuan',
                  suffixIcon: Icons.arrow_forward_ios,
                  readOnly: true,
                  onTap: () async {
                    SatuanDialog.showSatuanDialog(
                      context,
                      _listSatuan,
                      (newSatuan) async {
                        if (newSatuan.isNotEmpty) {
                          await DatabaseHelper().insertSatuan(newSatuan);
                          if (mounted) {
                            _loadSatuan();
                            setState(() {
                              _satuanController.text =
                                  newSatuan; // Set the text field value immediately
                            });
                          }
                        }
                      },
                      (id, updatedSatuan) async {
                        if (updatedSatuan.isNotEmpty) {
                          await DatabaseHelper()
                              .updateSatuan(id, updatedSatuan);
                          if (mounted) {
                            _loadSatuan();
                          }
                        }
                      },
                      (id) async {
                        await DatabaseHelper().deleteSatuan(id);
                        if (mounted) {
                          _loadSatuan();
                        }
                      },
                      (selectedSatuan) {
                        if (mounted) {
                          setState(() {
                            _satuanController.text = selectedSatuan;
                          });
                        }
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

                // Tombol Simpan
                OutlinedButton(
                  onPressed:
                      _saveProduk, // Panggil fungsi _saveProduk saat tombol simpan ditekan
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

  // Fungsi untuk membangun TextFormField
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
                  onTap: onSuffixIconTap, // Handle suffix icon tap
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
  final formatter = NumberFormat('#,###', 'en_US'); // Gunakan format titik

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final newText = newValue.text
        .replaceAll('.', '')
        .replaceAll(',', ''); // Hilangkan koma dan titik
    final number = int.parse(newText);
    final newString = formatter
        .format(number)
        .replaceAll(',', '.'); // Ganti koma dengan titik

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

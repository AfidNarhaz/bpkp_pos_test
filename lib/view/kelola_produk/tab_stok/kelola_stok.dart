import 'package:bpkp_pos_test/view/kelola_produk/tab_stok/pop_up_satuan.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/database/database_helper.dart'; // Import DatabaseHelper

class KelolaStokPage extends StatefulWidget {
  final int productId;
  final String? initialStok;
  final String? initialMinStok;
  final String? initialSatuan;

  const KelolaStokPage({
    super.key,
    required this.productId,
    this.initialStok,
    this.initialMinStok,
    this.initialSatuan,
  });

  @override
  KelolaStokPageState createState() => KelolaStokPageState();
}

class KelolaStokPageState extends State<KelolaStokPage> {
  List<Map<String, dynamic>> _listSatuan = [];

  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _minStokController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockData();
    _loadSatuan(); // Load satuan data
  }

  Future<void> _loadStockData() async {
    final db = await DatabaseHelper().database;
    final stockData = await db.query(
      'stok',
      where: 'product_id = ?',
      whereArgs: [widget.productId],
    );

    if (stockData.isNotEmpty) {
      final stock = stockData.first;
      _stokController.text = stock['jumlah'].toString();
      _minStokController.text = stock['minStok'].toString();
      _satuanController.text = stock['satuan'] as String;
    } else {
      _stokController.text = widget.initialStok ?? '';
      _minStokController.text = widget.initialMinStok ?? '';
      _satuanController.text = widget.initialSatuan ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // set background color
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Kelola Stok'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form untuk input data stok produk
            TextFormField(
              controller: _stokController,
              decoration: InputDecoration(
                labelText: 'Stok Produk',
                fillColor: Colors.blue[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            SizedBox(height: 16.0),
            // Form untuk input data minimum stok
            TextFormField(
              controller: _minStokController,
              decoration: InputDecoration(
                labelText: 'Minimum Stok',
                fillColor: Colors.blue[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            SizedBox(height: 16.0),
            // Form untuk satuan unit stok
            _buildTextField(
              controller: _satuanController,
              label: 'Pilih Satuan Unit',
              suffixIcon: Icons.arrow_forward_ios,
              readOnly: true,
              onTap: () {
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
                      await DatabaseHelper().updateSatuan(id, updatedSatuan);
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
            SizedBox(height: 16.0),
            // Tombol Simpan
            ElevatedButton(
              onPressed: () {
                final stok = _stokController.text;
                final minStok = _minStokController.text;
                final satuan = _satuanController.text;

                // Logika untuk menyimpan data
                debugPrint(
                    'Stok: $stok, Minimum Stok: $minStok, Satuan: $satuan');

                // Tambahkan logika penyimpanan data ke database/data table
                saveProductData(stok, minStok, satuan, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent, // Warna tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Bentuk tombol
                ),
              ),
              child: Text(
                'Simpan',
                style: TextStyle(color: AppColors.text), // Teks tombol
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveProductData(
      String stok, String minStok, String satuan, BuildContext context) async {
    final db = await DatabaseHelper().database;
    final stockData = await db.query(
      'stok',
      where: 'product_id = ?',
      whereArgs: [widget.productId],
    );

    if (stockData.isNotEmpty) {
      // Update existing stock data
      await DatabaseHelper()
          .updateProductData(widget.productId, stok, minStok, satuan);
    } else {
      // Insert new stock data
      await DatabaseHelper()
          .insertStockData(widget.productId, stok, minStok, satuan);
    }

    debugPrint(
        'Data disimpan ke database: Stok: $stok, Minimum Stok: $minStok, Satuan: $satuan');

    // Gabungkan data stok dengan data produk yang sedang ditambahkan atau di-edit
    await mergeWithProductData(stok, minStok, satuan, context);
  }

  Future<void> mergeWithProductData(
      String stok, String minStok, String satuan, BuildContext context) async {
    // Implementasikan logika penggabungan data stok dengan data produk
    debugPrint(
        'Data stok digabungkan dengan data produk: Stok: $stok, Minimum Stok: $minStok, Satuan: $satuan');

    // Kembali ke halaman sebelumnya dengan data stok
    if (mounted) {
      Navigator.pop(
          context, {'stok': stok, 'minStok': minStok, 'satuan': satuan});
    }
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

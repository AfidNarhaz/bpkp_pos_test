import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/penjualan/transaksi_berhasil.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger = Logger();

class PembayaranPage extends StatefulWidget {
  final List<Map<String, dynamic>> keranjang;
  final num totalTagihan;
  final String namaKasir;
  final Future<void> Function()? onResetKeranjang; // <-- Tambahkan ini

  const PembayaranPage({
    super.key,
    required this.keranjang,
    required this.totalTagihan,
    required this.namaKasir,
    this.onResetKeranjang, // <-- Tambahkan ini
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final NumberFormat formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  final TextEditingController tunaiController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    tunaiController.addListener(() {
      if (_isFormatting) return;
      final text = tunaiController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final uangDiterima = text.isEmpty ? 0 : int.parse(text);
      setState(() {
        isButtonEnabled = uangDiterima >= widget.totalTagihan;
      });

      // Format otomatis
      if (tunaiController.text != formatCurrency.format(uangDiterima)) {
        _isFormatting = true;
        tunaiController.text =
            uangDiterima == 0 ? '' : formatCurrency.format(uangDiterima);
        tunaiController.selection = TextSelection.fromPosition(
          TextPosition(offset: tunaiController.text.length),
        );
        _isFormatting = false;
      }
    });
  }

  Future<void> _clearKeranjang() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('keranjang');
    setState(() {
      widget.keranjang.clear();
      tunaiController.clear();
    });
  }

  void _showSimpanDialog() {
    final TextEditingController keteranganController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keterangan Pesanan'),
        content: TextField(
          controller: keteranganController,
          decoration: const InputDecoration(
            hintText: 'Masukkan keterangan pesanan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Simpan & Cetak logika di sini
              Navigator.pop(context);
              // Implementasi simpan & cetak
            },
            child: const Text('Simpan & Cetak Pesanan'),
          ),
          TextButton(
            onPressed: () {
              // Simpan logika di sini
              Navigator.pop(context);
              // Implementasi simpan saja
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tunaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _showSimpanDialog,
            child: const Text(
              'Simpan',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detail Pesanan:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 75, // Atur tinggi sesuai kebutuhan
                child: ListView.separated(
                  itemCount: widget.keranjang.length,
                  itemBuilder: (context, index) {
                    final item = widget.keranjang[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      title: Text(item['nama']),
                      subtitle: Text(
                        '${formatCurrency.format(item['hargaNego'] ?? item['hargaJual'])} x ${item['qty']}',
                      ),
                      trailing: Text(
                        formatCurrency.format(item['total']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Tagihan: ${formatCurrency.format(widget.totalTagihan)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(),
              const Text(
                'Tunai',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextFormField(
                  controller: tunaiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Uang yang diterima',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isButtonEnabled
                      ? () async {
                          final text = tunaiController.text
                              .replaceAll(RegExp(r'[^0-9]'), '');
                          final uangDiterima =
                              text.isEmpty ? 0 : int.parse(text);
                          final totalTagihan = widget.totalTagihan;
                          final keranjang = widget.keranjang;
                          final namaKasir = widget.namaKasir;

                          try {
                            await DatabaseHelper().insertPenjualan(keranjang);
                            // Jangan clear keranjang di sini!
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransaksiBerhasilPage(
                                  totalTagihan: totalTagihan,
                                  uangDiterima: uangDiterima,
                                  keranjang: List<Map<String, dynamic>>.from(
                                      keranjang), // Kirim salinan keranjang
                                  namaKasir: namaKasir,
                                  onTransaksiBaru: widget.onResetKeranjang,
                                ),
                              ),
                            );
                          } catch (err) {
                            logger.e(err);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Terjadi kesalahan saat transaksi: $err')));
                          }
                        }
                      : null, // Disable jika tidak memenuhi syarat
                  child: const Text('Terima',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),

              // Tombol Uang Pas tetap di bawahnya
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final totalTagihan = widget.totalTagihan;
                    final uangDiterima = widget.totalTagihan;
                    final keranjang = widget.keranjang;
                    final namaKasir = widget.namaKasir;

                    try {
                      await DatabaseHelper().insertPenjualan(keranjang);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransaksiBerhasilPage(
                            totalTagihan: totalTagihan,
                            uangDiterima: uangDiterima,
                            keranjang: List<Map<String, dynamic>>.from(
                                keranjang), // Kirim salinan keranjang
                            namaKasir: namaKasir,
                            onTransaksiBaru: _clearKeranjang,
                          ),
                        ),
                      );
                    } catch (err) {
                      logger.e(err);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Terjadi kesalahan saat transaksi: $err')));
                    }
                  },
                  child: const Text('Uang Pas',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

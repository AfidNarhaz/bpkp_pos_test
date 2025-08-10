import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/transaksi/transaksi_berhasil.dart';

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

  Future<void> _clearKeranjang() async {
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
  void initState() {
    super.initState();
    tunaiController.addListener(() {
      final text = tunaiController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) {
        tunaiController.value = TextEditingValue(text: '');
        return;
      }
      final formatted = formatCurrency.format(int.parse(text));
      tunaiController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    // Ambil nilai uang diterima dari input
                    final text =
                        tunaiController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final uangDiterima = text.isEmpty ? 0 : int.parse(text);
                    final totalTagihan = widget.totalTagihan;
                    final keranjang = widget.keranjang;
                    // ignore: unused_local_variable
                    final namaKasir = widget.namaKasir;

                    if (uangDiterima < totalTagihan) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Uang diterima kurang dari total tagihan!')),
                      );
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransaksiBerhasilPage(
                          totalTagihan: totalTagihan,
                          uangDiterima: uangDiterima,
                          keranjang: keranjang,
                          namaKasir: namaKasir,
                          onTransaksiBaru:
                              widget.onResetKeranjang, // <-- Perbaiki ini
                        ),
                      ),
                    );

                    // Jika perlu, lakukan sesuatu dengan hasilnya
                    if (result == true) {
                      // Misalnya, jika ingin mengosongkan keranjang setelah transaksi berhasil
                      _clearKeranjang();
                    }
                  },
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
                  onPressed: () {
                    final totalTagihan = widget.totalTagihan;
                    final uangDiterima = widget.totalTagihan;
                    final keranjang = widget.keranjang;
                    // ignore: unused_local_variable
                    final namaKasir = widget.namaKasir;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransaksiBerhasilPage(
                          totalTagihan: totalTagihan,
                          uangDiterima: uangDiterima,
                          keranjang: keranjang,
                          namaKasir: widget
                              .namaKasir, // <-- gunakan namaKasir dari widget
                          onTransaksiBaru: _clearKeranjang,
                        ),
                      ),
                    );
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

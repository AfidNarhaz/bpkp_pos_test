import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/penjualan/struk.dart';
import 'package:bpkp_pos_test/view/penjualan/transaksi_page.dart';
// Pastikan ada model user
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('role') ?? '';
}

class TransaksiBerhasilPage extends StatelessWidget {
  final num totalTagihan;
  final num uangDiterima;
  final List<Map<String, dynamic>> keranjang;
  final String namaKasir;
  final Future<void> Function()? onTransaksiBaru;

  const TransaksiBerhasilPage({
    super.key,
    required this.totalTagihan,
    required this.uangDiterima,
    required this.keranjang,
    required this.namaKasir,
    this.onTransaksiBaru,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tanggal = DateFormat('dd/MM/yyyy').format(now);
    final jam = DateFormat('HH:mm').format(now);
    final kembalian = uangDiterima - totalTagihan;
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    String generateStrukCode() {
      final random =
          DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
      return '#INV-${random.substring(random.length - 8)}';
    }

    // Widget utama dengan PopScope
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (onTransaksiBaru != null) {
            await onTransaksiBaru!();
          } else {
            keranjang.clear();
          }
          final role = await getUserRole();
          Widget page;
          if (role == 'admin') {
            page = const TransaksiPage(showBackButton: true);
          } else {
            page = const TransaksiPage(showBackButton: false);
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => page),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Tidak ada tombol back
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Transaksi Berhasil',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$tanggal, $jam',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 18)),
                  Text(formatCurrency.format(totalTagihan),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diterima', style: TextStyle(fontSize: 18)),
                  Text(formatCurrency.format(uangDiterima),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian', style: TextStyle(fontSize: 18)),
                  Text(formatCurrency.format(kembalian),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Hubungkan cetak struk ke printer
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cetak Struk'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KirimStrukPage(
                              namaKasir: namaKasir,
                              waktuTransaksi: now,
                              noStruk: generateStrukCode(),
                              jenisPembayaran: 'Tunai',
                              keranjang: keranjang,
                              totalTagihan: totalTagihan,
                              uangDiterima: uangDiterima,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Kirim Struk'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (onTransaksiBaru != null) {
                          await onTransaksiBaru!(); // Reset keranjang
                        } else {
                          keranjang.clear();
                        }
                        final role = await getUserRole();
                        Widget page;
                        if (role == 'admin') {
                          page = const TransaksiPage(showBackButton: true);
                        } else {
                          page = const TransaksiPage(showBackButton: false);
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => page),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Transaksi Baru'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

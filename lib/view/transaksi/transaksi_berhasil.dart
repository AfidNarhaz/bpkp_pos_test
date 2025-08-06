import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/transaksi/struk.dart';
import 'package:bpkp_pos_test/view/transaksi/transaksi_page.dart';

class TransaksiBerhasilPage extends StatelessWidget {
  final num totalTagihan;
  final num uangDiterima;
  final List<Map<String, dynamic>> keranjang;
  final String namaKasir;
  final Future<void> Function()?
      onTransaksiBaru; // Ubah tipe menjadi Future<void> Function()?

  const TransaksiBerhasilPage({
    super.key,
    required this.totalTagihan,
    required this.uangDiterima,
    required this.keranjang,
    required this.namaKasir,
    this.onTransaksiBaru, // Tambahkan ini di konstruktor
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

    return Scaffold(
      appBar: AppBar(),
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
                      // TODO: Cetak Struk
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
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
                    onPressed: () {
                      // TODO: Cetak Pesanan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cetak Pesanan'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (onTransaksiBaru != null) {
                        await onTransaksiBaru!();
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const TransaksiPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
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
    );
  }
}

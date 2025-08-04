import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaksiBerhasilPage extends StatelessWidget {
  final num totalTagihan;
  final num uangDiterima;

  const TransaksiBerhasilPage({
    super.key,
    required this.totalTagihan,
    required this.uangDiterima,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tanggal = DateFormat('dd/MM/yyyy').format(now);
    final jam = DateFormat('HH:mm').format(now);
    final kembalian = uangDiterima - totalTagihan;
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}

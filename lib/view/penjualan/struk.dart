import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KirimStrukPage extends StatelessWidget {
  final String namaKasir;
  final DateTime waktuTransaksi;
  final String noStruk;
  final String jenisPembayaran;
  final List<Map<String, dynamic>> keranjang;
  final num totalTagihan;
  final num uangDiterima;

  const KirimStrukPage({
    super.key,
    required this.namaKasir,
    required this.waktuTransaksi,
    required this.noStruk,
    required this.jenisPembayaran,
    required this.keranjang,
    required this.totalTagihan,
    required this.uangDiterima,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final waktu = DateFormat('dd/MM/yyyy HH:mm').format(waktuTransaksi);
    final uangDiterimaDouble = uangDiterima.toDouble();
    final totalTagihanDouble = totalTagihan.toDouble();
    final kembalian = uangDiterimaDouble - totalTagihanDouble;
    final totalProduk =
        keranjang.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 1));
    final subtotal = keranjang.fold<num>(
        0, (sum, item) => sum + (item['total'] as num? ?? 0));

    Future<Uint8List> generatePdf(PdfPageFormat format) async {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Kasir: $namaKasir'),
                pw.Text('Waktu: $waktu'),
                pw.Text('No. Struk: $noStruk'),
                pw.Text('Jenis Pembayaran: $jenisPembayaran'),
                pw.Divider(),
                pw.Center(child: pw.Text('###LUNAS###')),
                pw.Divider(),
                ...keranjang.map((item) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item['nama'],
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${formatCurrency.format(item['hargaNego'] ?? item['hargaJual'])} x${item['qty']}',
                            ),
                            pw.Text(formatCurrency.format(item['total'])),
                          ],
                        ),
                      ],
                    )),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal'),
                    pw.Text(formatCurrency.format(subtotal)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total ($totalProduk Produk)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(formatCurrency.format(totalTagihanDouble),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Bayar'),
                    pw.Text(formatCurrency.format(uangDiterimaDouble)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kembalian'),
                    pw.Text(formatCurrency.format(kembalian)),
                  ],
                ),
              ],
            );
          },
        ),
      );
      return pdf.save();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pratinjau')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kasir:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(namaKasir,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Waktu:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(waktu,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No. Struk:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(noStruk,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jenis Pembayaran:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(jenisPembayaran,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              const Center(
                  child: Text('###LUNAS###',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(),
              ...keranjang.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nama'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${formatCurrency.format(item['hargaNego'] ?? item['hargaJual'])} x${item['qty']}',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatCurrency.format(item['total']),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(formatCurrency.format(subtotal),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total ($totalProduk Produk)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatCurrency.format(totalTagihan),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bayar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatCurrency.format(uangDiterima),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatCurrency.format(kembalian),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.share),
          onPressed: () async {
            await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => generatePdf(format),
            );
          }),
    );
  }
}

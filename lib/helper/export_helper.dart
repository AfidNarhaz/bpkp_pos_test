import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExportHelper {
  static Future<void> exportToPDF({
    required Map<String, dynamic> labaRugiData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = pw.Document();

      // Ambil data
      final penjualanTunai = labaRugiData['penjualanTunai'] as double;
      final penjualanNonTunai = labaRugiData['penjualanNonTunai'] as double;
      final totalPendapatan = labaRugiData['totalPendapatan'] as double;
      final totalBiaya = labaRugiData['totalBiaya'] as double;
      final labaKotor = labaRugiData['labaKotor'] as double;
      final gajiPegawai = labaRugiData['gajiPegawai'] as double;
      final sewaTempat = labaRugiData['sewaTempat'] as double;
      final listrikAirGas = labaRugiData['listrikAirGas'] as double;
      final internetSistem = labaRugiData['internetSistem'] as double;
      final transportasi = labaRugiData['transportasi'] as double;
      final totalBebanOperasional =
          labaRugiData['totalBebanOperasional'] as double;
      final labaBersih = labaRugiData['labaBersih'] as double;
      final marginLabaKotor = labaRugiData['marginLabaKotor'] as double;
      final marginLabaBersih = labaRugiData['marginLabaBersih'] as double;

      final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final currencyFormat = NumberFormat('#,##0', 'id_ID');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'LAPORAN LABA RUGI',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // A. PENDAPATAN
            pw.Text(
              'A. PENDAPATAN',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRow(
              'Penjualan Tunai',
              'Rp${currencyFormat.format(penjualanTunai)}',
            ),
            _buildPdfRow(
              'Penjualan Non-Tunai (QRIS, Kartu)',
              'Rp${currencyFormat.format(penjualanNonTunai)}',
            ),
            _buildPdfRowBold(
              'Total Pendapatan',
              'Rp${currencyFormat.format(totalPendapatan)}',
            ),
            pw.SizedBox(height: 16),

            // B. HARGA POKOK PENJUALAN
            pw.Text(
              'B. HARGA POKOK PENJUALAN (HPP)',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRow(
              'Total HPP',
              'Rp${currencyFormat.format(totalBiaya)}',
            ),
            pw.SizedBox(height: 16),

            // C. LABA KOTOR
            pw.Text(
              'C. LABA KOTOR',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRowBold(
              'Laba Kotor (A - B)',
              'Rp${currencyFormat.format(labaKotor)}',
            ),
            _buildPdfRow(
              'Margin Laba Kotor',
              '${marginLabaKotor.toStringAsFixed(2)}%',
            ),
            pw.SizedBox(height: 16),

            // D. BEBAN OPERASIONAL
            pw.Text(
              'D. BEBAN OPERASIONAL',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRow('Gaji & Tunjangan Pegawai',
                'Rp${currencyFormat.format(gajiPegawai)}'),
            _buildPdfRow(
                'Sewa Tempat', 'Rp${currencyFormat.format(sewaTempat)}'),
            _buildPdfRow('Listrik, Air & Gas',
                'Rp${currencyFormat.format(listrikAirGas)}'),
            _buildPdfRow('Internet & Sistem POS',
                'Rp${currencyFormat.format(internetSistem)}'),
            _buildPdfRow(
                'Transportasi', 'Rp${currencyFormat.format(transportasi)}'),
            _buildPdfRowBold(
              'Total Beban Operasional',
              'Rp${currencyFormat.format(totalBebanOperasional)}',
            ),
            pw.SizedBox(height: 16),

            // E. LABA BERSIH
            pw.Text(
              'E. LABA BERSIH',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRowBold(
              'Laba Bersih (C - D)',
              'Rp${currencyFormat.format(labaBersih)}',
            ),
            _buildPdfRow(
              'Margin Laba Bersih',
              '${marginLabaBersih.toStringAsFixed(2)}%',
            ),
            pw.SizedBox(height: 20),

            // F. ANALISIS
            pw.Text(
              'F. ANALISIS PERFORMA',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfRow(
                'Margin Laba Kotor', '${marginLabaKotor.toStringAsFixed(2)}%'),
            _buildPdfRow('Margin Laba Bersih',
                '${marginLabaBersih.toStringAsFixed(2)}%'),
            _buildPdfRow(
              'Rasio HPP terhadap Penjualan',
              '${labaRugiData['rasioHPP'].toStringAsFixed(2)}%',
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm:ss', 'id_ID').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      );

      // Simpan file
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_LabaRugi_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      rethrow;
    }
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }

  static pw.Widget _buildPdfRowBold(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static Future<void> exportToExcel({
    required Map<String, dynamic> labaRugiData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Create a new Excel document
      final Workbook workbook = Workbook();
      final Worksheet worksheet = workbook.worksheets[0];

      final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final currencyFormat = NumberFormat('#,##0', 'id_ID');

      // Ambil data
      final penjualanTunai = labaRugiData['penjualanTunai'] as double;
      final penjualanNonTunai = labaRugiData['penjualanNonTunai'] as double;
      final totalPendapatan = labaRugiData['totalPendapatan'] as double;
      final totalBiaya = labaRugiData['totalBiaya'] as double;
      final labaKotor = labaRugiData['labaKotor'] as double;
      final gajiPegawai = labaRugiData['gajiPegawai'] as double;
      final sewaTempat = labaRugiData['sewaTempat'] as double;
      final listrikAirGas = labaRugiData['listrikAirGas'] as double;
      final internetSistem = labaRugiData['internetSistem'] as double;
      final transportasi = labaRugiData['transportasi'] as double;
      final totalBebanOperasional =
          labaRugiData['totalBebanOperasional'] as double;
      final labaBersih = labaRugiData['labaBersih'] as double;
      final marginLabaKotor = labaRugiData['marginLabaKotor'] as double;
      final marginLabaBersih = labaRugiData['marginLabaBersih'] as double;

      int row = 1;

      // Header
      worksheet.getRangeByIndex(row, 1).value = 'LAPORAN LABA RUGI';
      row++;
      worksheet.getRangeByIndex(row, 1).value =
          'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
      row += 2;

      // A. PENDAPATAN
      worksheet.getRangeByIndex(row, 1).value = 'A. PENDAPATAN';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Penjualan Tunai';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(penjualanTunai)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value =
          'Penjualan Non-Tunai (QRIS, Kartu)';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(penjualanNonTunai)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Total Pendapatan';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(totalPendapatan)}';
      row += 2;

      // B. HARGA POKOK PENJUALAN
      worksheet.getRangeByIndex(row, 1).value =
          'B. HARGA POKOK PENJUALAN (HPP)';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Total HPP';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(totalBiaya)}';
      row += 2;

      // C. LABA KOTOR
      worksheet.getRangeByIndex(row, 1).value = 'C. LABA KOTOR';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Laba Kotor (A - B)';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(labaKotor)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Margin Laba Kotor';
      worksheet.getRangeByIndex(row, 2).value =
          '${marginLabaKotor.toStringAsFixed(2)}%';
      row += 2;

      // D. BEBAN OPERASIONAL
      worksheet.getRangeByIndex(row, 1).value = 'D. BEBAN OPERASIONAL';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Gaji & Tunjangan Pegawai';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(gajiPegawai)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Sewa Tempat';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(sewaTempat)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Listrik, Air & Gas';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(listrikAirGas)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Internet & Sistem POS';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(internetSistem)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Transportasi';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(transportasi)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Total Beban Operasional';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(totalBebanOperasional)}';
      row += 2;

      // E. LABA BERSIH
      worksheet.getRangeByIndex(row, 1).value = 'E. LABA BERSIH';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Laba Bersih (C - D)';
      worksheet.getRangeByIndex(row, 2).value =
          'Rp${currencyFormat.format(labaBersih)}';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Margin Laba Bersih';
      worksheet.getRangeByIndex(row, 2).value =
          '${marginLabaBersih.toStringAsFixed(2)}%';
      row += 2;

      // F. ANALISIS
      worksheet.getRangeByIndex(row, 1).value = 'F. ANALISIS PERFORMA';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Margin Laba Kotor';
      worksheet.getRangeByIndex(row, 2).value =
          '${marginLabaKotor.toStringAsFixed(2)}%';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Margin Laba Bersih';
      worksheet.getRangeByIndex(row, 2).value =
          '${marginLabaBersih.toStringAsFixed(2)}%';
      row++;
      worksheet.getRangeByIndex(row, 1).value = 'Rasio HPP terhadap Penjualan';
      worksheet.getRangeByIndex(row, 2).value =
          '${labaRugiData['rasioHPP'].toStringAsFixed(2)}%';

      // Simpan file
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_LabaRugi_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(workbook.saveAsStream());
      workbook.dispose();
    } catch (e) {
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExportHelper {
  // =======================
  // PARSER ANGKA AMAN
  // =======================
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  // =======================
  // GET DOWNLOAD DIRECTORY
  // =======================
  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  // =======================
  // EXPORT PDF
  // =======================
  static Future<File> exportToPDF({
    required Map<String, dynamic> labaRugiData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final penjualanTunai = _toDouble(labaRugiData['penjualanTunai']);
    final penjualanNonTunai = _toDouble(labaRugiData['penjualanNonTunai']);
    final totalPendapatan = _toDouble(labaRugiData['totalPendapatan']);
    final totalBiaya = _toDouble(labaRugiData['totalBiaya']);
    final labaKotor = _toDouble(labaRugiData['labaKotor']);
    final gajiPegawai = _toDouble(labaRugiData['gajiPegawai']);
    final sewaTempat = _toDouble(labaRugiData['sewaTempat']);
    final listrikAirGas = _toDouble(labaRugiData['listrikAirGas']);
    final internetSistem = _toDouble(labaRugiData['internetSistem']);
    final transportasi = _toDouble(labaRugiData['transportasi']);
    final totalBebanOperasional =
        _toDouble(labaRugiData['totalBebanOperasional']);
    final labaBersih = _toDouble(labaRugiData['labaBersih']);
    final marginLabaKotor = _toDouble(labaRugiData['marginLabaKotor']);
    final marginLabaBersih = _toDouble(labaRugiData['marginLabaBersih']);
    final rasioHPP = _toDouble(labaRugiData['rasioHPP']);

    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currency = NumberFormat('#,##0', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('LAPORAN LABA RUGI',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          _title('A. PENDAPATAN'),
          _row('Penjualan Tunai', penjualanTunai, currency),
          _row('Penjualan Non-Tunai', penjualanNonTunai, currency),
          _rowBold('Total Pendapatan', totalPendapatan, currency),
          _title('B. HPP'),
          _row('Total HPP', totalBiaya, currency),
          _title('C. LABA KOTOR'),
          _rowBold('Laba Kotor', labaKotor, currency),
          _rowText(
              'Margin Laba Kotor', '${marginLabaKotor.toStringAsFixed(2)}%'),
          _title('D. BEBAN OPERASIONAL'),
          _row('Gaji Pegawai', gajiPegawai, currency),
          _row('Sewa Tempat', sewaTempat, currency),
          _row('Listrik, Air & Gas', listrikAirGas, currency),
          _row('Internet & Sistem', internetSistem, currency),
          _row('Transportasi', transportasi, currency),
          _rowBold('Total Beban Operasional', totalBebanOperasional, currency),
          _title('E. LABA BERSIH'),
          _rowBold('Laba Bersih', labaBersih, currency),
          _rowText(
              'Margin Laba Bersih', '${marginLabaBersih.toStringAsFixed(2)}%'),
          _title('F. ANALISIS'),
          _rowText('Rasio HPP terhadap Penjualan',
              '${rasioHPP.toStringAsFixed(2)}%'),
          pw.Divider(),
          pw.Text(
            'Dicetak: ${DateFormat('dd MMMM yyyy HH:mm:ss', 'id_ID').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    final dir = await _getDownloadDirectory();
    final file = File(
        '${dir.path}/Laporan_LabaRugi_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // =======================
  // EXPORT EXCEL
  // =======================
  static Future<File> exportToExcel({
    required Map<String, dynamic> labaRugiData,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currency = NumberFormat('#,##0', 'id_ID');

    int row = 1;
    sheet.getRangeByIndex(row++, 1).value = 'LAPORAN LABA RUGI';
    sheet.getRangeByIndex(row++, 1).value =
        'Periode: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    row++;

    void write(String label, String value) {
      sheet.getRangeByIndex(row, 1).value = label;
      sheet.getRangeByIndex(row, 2).value = value;
      row++;
    }

    write('Penjualan Tunai',
        'Rp${currency.format(_toDouble(labaRugiData['penjualanTunai']))}');
    write('Penjualan Non-Tunai',
        'Rp${currency.format(_toDouble(labaRugiData['penjualanNonTunai']))}');
    write('Total Pendapatan',
        'Rp${currency.format(_toDouble(labaRugiData['totalPendapatan']))}');
    write('Total HPP',
        'Rp${currency.format(_toDouble(labaRugiData['totalBiaya']))}');
    write('Laba Bersih',
        'Rp${currency.format(_toDouble(labaRugiData['labaBersih']))}');

    final dir = await _getDownloadDirectory();
    final file = File(
        '${dir.path}/Laporan_LabaRugi_${DateTime.now().millisecondsSinceEpoch}.xlsx');

    await file.writeAsBytes(workbook.saveAsStream());
    workbook.dispose();

    return file;
  }

  // =======================
  // PDF WIDGET HELPER
  // =======================
  static pw.Widget _title(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _row(String label, double value, NumberFormat format) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text('Rp${format.format(value)}',
              style: const pw.TextStyle(fontSize: 11)),
        ],
      );

  static pw.Widget _rowBold(String label, double value, NumberFormat format) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text('Rp${format.format(value)}',
              style:
                  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      );

  static pw.Widget _rowText(String label, String value) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      );
}

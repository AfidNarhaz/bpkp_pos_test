import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/drawer.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:bpkp_pos_test/helper/export_helper.dart';
import 'package:bpkp_pos_test/view/laporan/laba_rugi/input_laba_rugi.dart';

class LabaRugiPage extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const LabaRugiPage({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  State<LabaRugiPage> createState() => _LabaRugiPageState();
}

class _LabaRugiPageState extends State<LabaRugiPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _labaRugiFuture;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Gunakan parameter dari widget atau default ke hari ini
    final now = DateTime.now();
    _startDate = widget.startDate ?? DateTime(now.year, now.month, 1);
    _endDate = widget.endDate ?? now;
    _labaRugiFuture = _calculateLabaRugi();
  }

  Future<Map<String, dynamic>> _calculateLabaRugi() async {
    try {
      // Ambil data penjualan
      final penjualan = await _dbHelper.getListPenjualan(
        startDate: _startDate,
        endDate: _endDate,
      );

      // Ambil data pembelian
      final pembelian = await _dbHelper.getListPembelian(
        startDate: _startDate,
        endDate: _endDate,
      );

      // === A. PENDAPATAN ===
      double penjualanTunai = 0;
      double totalPendapatan = 0;

      for (var item in penjualan) {
        final amount = (item['total_transaksi'] as num?)?.toDouble() ?? 0;
        penjualanTunai += amount;
      }

      // Total Pendapatan Bersih = Penjualan Tunai
      totalPendapatan = penjualanTunai;

      // === B. HARGA POKOK PENJUALAN (HPP) ===
      // HPP = Persediaan Awal + Pembelian Barang Dagang - Persediaan Akhir
      double persediaanAwal =
          0; // Bisa diambil dari database inventory awal periode
      double pembelianBarang = 0;
      double persediaanAkhir =
          0; // Bisa diambil dari database inventory akhir periode

      for (var item in pembelian) {
        final detail = await _dbHelper.getDetailBarangPembelian(item['code']);
        for (var barang in detail) {
          pembelianBarang +=
              ((barang['harga_satuan'] as num?)?.toDouble() ?? 0) *
                  ((barang['jumlah'] as num?)?.toInt() ?? 0);
        }
      }

      // Total HPP = Persediaan Awal + Pembelian - Persediaan Akhir
      double totalBiaya = persediaanAwal + pembelianBarang - persediaanAkhir;

      // === C. LABA KOTOR ===
      double labaKotor = totalPendapatan - totalBiaya;

      // === D. BEBAN OPERASIONAL (dari database) ===
      final bebanOperasional =
          await _dbHelper.getOperationalExpensesInRange(_startDate, _endDate);

      double gajiPegawai = bebanOperasional['gajiPegawai'] ?? 0;
      double sewaTempat = bebanOperasional['sewaTempat'] ?? 0;
      double listrikAirGas = bebanOperasional['listrikAirGas'] ?? 0;
      double transportasi = bebanOperasional['transportasi'] ?? 0;
      double penyusutanPeralatan = bebanOperasional['penyusutanPeralatan'] ?? 0;
      double biayaLainnya = bebanOperasional['biayaLainnya'] ?? 0;

      double totalBebanOperasional = gajiPegawai +
          sewaTempat +
          listrikAirGas +
          transportasi +
          penyusutanPeralatan +
          biayaLainnya;

      // === E. LABA BERSIH ===
      double labaBersih = labaKotor - totalBebanOperasional;

      return {
        'penjualanTunai': penjualanTunai,
        'totalPendapatan': totalPendapatan,
        'persediaanAwal': persediaanAwal,
        'pembelianBarang': pembelianBarang,
        'persediaanAkhir': persediaanAkhir,
        'totalBiaya': totalBiaya,
        'labaKotor': labaKotor,
        'gajiPegawai': gajiPegawai,
        'sewaTempat': sewaTempat,
        'listrikAirGas': listrikAirGas,
        'transportasi': transportasi,
        'penyusutanPeralatan': penyusutanPeralatan,
        'biayaLainnya': biayaLainnya,
        'totalBebanOperasional': totalBebanOperasional,
        'labaBersih': labaBersih,
      };
    } catch (e) {
      rethrow;
    }
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _labaRugiFuture = _calculateLabaRugi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Laba Rugi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: LaporanDrawer(parentContext: context),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _labaRugiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada data'));
          }

          final data = snapshot.data!;
          final penjualanTunai = (data['penjualanTunai'] as double?) ?? 0;
          final totalPendapatan = (data['totalPendapatan'] as double?) ?? 0;
          final persediaanAwal = (data['persediaanAwal'] as double?) ?? 0;
          final pembelianBarang = (data['pembelianBarang'] as double?) ?? 0;
          final persediaanAkhir = (data['persediaanAkhir'] as double?) ?? 0;
          final totalBiaya = (data['totalBiaya'] as double?) ?? 0;
          final labaKotor = (data['labaKotor'] as double?) ?? 0;
          final totalBebanOperasional =
              (data['totalBebanOperasional'] as double?) ?? 0;
          final labaBersih = (data['labaBersih'] as double?) ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Picker Widget
                DateRangePickerWidget(
                  onDateRangeChanged: _onDateRangeChanged,
                ),
                const SizedBox(height: 16),

                // Tombol Export
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ExportHelper.exportToPDF(
                            labaRugiData: data,
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✓ Laporan PDF berhasil diunduh'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ExportHelper.exportToExcel(
                            labaRugiData: data,
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('✓ Laporan Excel berhasil diunduh'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InputLabaRugiPage(),
                          ),
                        ).then((_) {
                          setState(() {
                            _labaRugiFuture = _calculateLabaRugi();
                          });
                        });
                      },
                      icon: const Icon(Icons.input),
                      label: const Text('Input'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // === A. PENDAPATAN ===
                _buildSectionHeader('A. PENDAPATAN'),
                _buildReportRow('Penjualan Tunai', penjualanTunai),
                _buildReportRow('Total Pendapatan Bersih', totalPendapatan,
                    isBold: true, color: Colors.green),
                const SizedBox(height: 16),

                // === B. HARGA POKOK PENJUALAN ===
                _buildSectionHeader('B. HARGA POKOK PENJUALAN (HPP)'),
                _buildReportRow('Persediaan Awal', persediaanAwal),
                _buildReportRow('Pembelian Barang Dagang', pembelianBarang),
                _buildReportRow('Persediaan Akhir', persediaanAkhir,
                    showInParentheses: true),
                _buildReportRow('Total HPP (COGS)', totalBiaya,
                    isBold: true, color: Colors.red),
                const SizedBox(height: 16),

                // === C. LABA KOTOR ===
                _buildSectionHeader('C. LABA KOTOR'),
                _buildReportRow('Laba Kotor (A - B)', labaKotor,
                    isBold: true, color: Colors.blue),
                const SizedBox(height: 16),

                // === D. BEBAN OPERASIONAL ===
                _buildSectionHeader('D. BEBAN OPERASIONAL'),
                _buildReportRow('Gaji Pegawai', data['gajiPegawai']),
                _buildReportRow('Sewa Tempat', data['sewaTempat']),
                _buildReportRow('Listrik dan Air', data['listrikAirGas']),
                _buildReportRow('Transportasi', data['transportasi']),
                _buildReportRow(
                    'Penyusutan Peralatan', data['penyusutanPeralatan']),
                _buildReportRow(
                    'Biaya Operasional Lainnya', data['biayaLainnya']),
                _buildReportRow(
                    'Total Beban Operasional', totalBebanOperasional,
                    isBold: true),
                const SizedBox(height: 16),

                // === E. LABA BERSIH ===
                _buildSectionHeader('E. LABA BERSIH'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: labaBersih >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: labaBersih >= 0 ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Formula
                      Text(
                        '= Laba Kotor – Beban Operasional',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Perhitungan breakdown
                      Text(
                        '= ${_formatCurrency(labaKotor)} – ${_formatCurrency(totalBebanOperasional)} = ${_formatCurrency(labaBersih)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Hasil akhir
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: labaBersih >= 0
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              labaBersih >= 0 ? 'LABA BERSIH' : 'RUGI BERSIH',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    labaBersih >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              _formatCurrency(labaBersih),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    labaBersih >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp${formatter.format(value)}';
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          left: BorderSide(color: Colors.blue.shade700, width: 4),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    double value, {
    bool isBold = false,
    bool isPercentage = false,
    Color? color,
    bool showInParentheses = false,
  }) {
    String valueText =
        isPercentage ? '${value.toStringAsFixed(2)}%' : _formatCurrency(value);
    if (showInParentheses) {
      valueText = '($valueText)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

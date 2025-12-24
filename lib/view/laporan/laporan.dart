import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/home/home_page.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/drawer.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String selectedDateRange = 'Pilih Tanggal';
  String comparisonDateRange = '';
  DateTime? startDate;
  DateTime? endDate;
  late Future<double> _totalPenjualanFuture;
  late Future<double> _labaBersihFuture;
  late Future<int> _totalTransaksiCountFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = now;
    _totalPenjualanFuture = _getTotalPenjualan();
    _labaBersihFuture = _getLabaBersih();
    _totalTransaksiCountFuture = _getTotalTransaksiCount();
  }

  Future<double> _getTotalPenjualan() async {
    try {
      if (startDate == null || endDate == null) {
        return 0;
      }

      final penjualan = await _dbHelper.getListPenjualan(
        startDate: startDate!,
        endDate: endDate!,
      );

      double total = 0;
      for (var item in penjualan) {
        final amount = (item['total_transaksi'] as num?)?.toDouble() ?? 0;
        total += amount;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getLabaBersih() async {
    try {
      if (startDate == null || endDate == null) {
        return 0;
      }

      // === A. PENDAPATAN ===
      final penjualan = await _dbHelper.getListPenjualan(
        startDate: startDate!,
        endDate: endDate!,
      );

      double penjualanTunai = 0;
      for (var item in penjualan) {
        final amount = (item['total_transaksi'] as num?)?.toDouble() ?? 0;
        penjualanTunai += amount;
      }

      // === B. HARGA POKOK PENJUALAN (HPP) ===
      final pembelian = await _dbHelper.getListPembelian(
        startDate: startDate!,
        endDate: endDate!,
      );

      double pembelianBarang = 0;
      for (var item in pembelian) {
        final detail = await _dbHelper.getDetailBarangPembelian(item['code']);
        for (var barang in detail) {
          pembelianBarang +=
              ((barang['harga_satuan'] as num?)?.toDouble() ?? 0) *
                  ((barang['jumlah'] as num?)?.toInt() ?? 0);
        }
      }

      // HPP = Pembelian (simple calculation)
      double totalBiaya = pembelianBarang;

      // === C. LABA KOTOR ===
      double labaKotor = penjualanTunai - totalBiaya;

      // === D. BEBAN OPERASIONAL ===
      final bebanOperasional =
          await _dbHelper.getOperationalExpensesInRange(startDate!, endDate!);

      double totalBebanOperasional = 0;
      bebanOperasional.forEach((key, value) {
        totalBebanOperasional += value;
      });

      // === E. LABA BERSIH ===
      double labaBersih = labaKotor - totalBebanOperasional;

      return labaBersih;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalTransaksiCount() async {
    try {
      if (startDate == null || endDate == null) {
        return 0;
      }

      final penjualan = await _dbHelper.getListPenjualan(
        startDate: startDate!,
        endDate: endDate!,
      );

      return penjualan.length;
    } catch (e) {
      return 0;
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return 'Rp${formatter.format(value)}';
  }

  Widget _buildReportCard(String title, String value, String growth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                  Text(
                    growth,
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B4B4B)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Laporan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Picker
                  DateRangePickerWidget(
                    onDateRangeChanged: (start, end) {
                      setState(() {
                        startDate = start;
                        endDate = end;
                        final dateFormat = DateFormat('dd/MM/yyyy');
                        selectedDateRange =
                            '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                        _totalPenjualanFuture = _getTotalPenjualan();
                        _labaBersihFuture = _getLabaBersih();
                        _totalTransaksiCountFuture = _getTotalTransaksiCount();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  if (comparisonDateRange.isNotEmpty)
                    Text(
                      "Dibandingkan $comparisonDateRange",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 12),

                  // Kartu laporan
                  FutureBuilder<double>(
                    future: _totalPenjualanFuture,
                    builder: (context, snapshot) {
                      String displayValue = 'Rp0';
                      if (snapshot.connectionState == ConnectionState.done) {
                        displayValue = _formatCurrency(snapshot.data ?? 0);
                      } else if (snapshot.hasError) {
                        displayValue = 'Error';
                      }
                      return _buildReportCard(
                          "Total Penjualan", displayValue, "0%");
                    },
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<double>(
                    future: _labaBersihFuture,
                    builder: (context, snapshot) {
                      String displayValue = 'Rp0';
                      if (snapshot.connectionState == ConnectionState.done) {
                        displayValue = _formatCurrency(snapshot.data ?? 0);
                      } else if (snapshot.hasError) {
                        displayValue = 'Error';
                      }
                      return _buildReportCard(
                          "Laba Bersih", displayValue, "0%");
                    },
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<int>(
                    future: _totalTransaksiCountFuture,
                    builder: (context, snapshot) {
                      String displayValue = '0';
                      if (snapshot.connectionState == ConnectionState.done) {
                        displayValue = (snapshot.data ?? 0).toString();
                      } else if (snapshot.hasError) {
                        displayValue = 'Error';
                      }
                      return _buildReportCard(
                          "Total Transaksi", displayValue, "0%");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

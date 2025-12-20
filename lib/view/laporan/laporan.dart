import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/home/home_page.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/drawer.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedDateRange = 'Pilih Tanggal';
  String comparisonDateRange = '';
  DateTime? startDate;
  DateTime? endDate;

  Widget _buildReportCard(String title, String value, String growth,
      {VoidCallback? onDetail}) {
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: onDetail,
              child: Text(
                "Lihat Detail",
                style: TextStyle(
                    color: Colors.red[400],
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
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
            'Beranda',
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
                  _buildReportCard("Total Penjualan", "Rp0", "0%"),
                  const SizedBox(height: 8),
                  _buildReportCard("Total Keuntungan", "Rp0", "0%"),
                  const SizedBox(height: 8),
                  _buildReportCard("Total Transaksi", "0", "0%"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

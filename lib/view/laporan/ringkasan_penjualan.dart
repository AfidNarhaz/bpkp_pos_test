import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/laporan/drawer.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';

class RingkasanPenjualanPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const RingkasanPenjualanPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<RingkasanPenjualanPage> createState() => _RingkasanPenjualanPageState();
}

class _RingkasanPenjualanPageState extends State<RingkasanPenjualanPage> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  Widget _buildRow(String label, int amount,
      {bool isNegative = false, bool isBold = false}) {
    final textStyle = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(
            "${isNegative ? '- ' : ''}Rp${amount.toString()}",
            style: textStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ringkasan Penjualan',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateRangePickerWidget(
              onDateRangeChanged: (start, end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                });
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Penjualan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Penjualan Kotor - (Diskon + Redeem Poin) + Pajak",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(),
                    _buildRow("Penjualan Kotor", 0),
                    _buildRow("Diskon", 0, isNegative: true),
                    _buildRow("Redeem Poin", 0, isNegative: true),
                    const Divider(),
                    _buildRow("Total Penjualan Bersih", 0, isBold: true),
                    _buildRow("Pajak", 0),
                    const Divider(),
                    _buildRow("Total Penjualan", 0, isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Keuntungan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total Penjualan Bersih - Harga Modal",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(),
                    _buildRow("Total Penjualan", 0),
                    _buildRow("Total Harga Pokok Penjualan", 0,
                        isNegative: true),
                    const Divider(),
                    _buildRow("Total Keuntungan", 0, isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

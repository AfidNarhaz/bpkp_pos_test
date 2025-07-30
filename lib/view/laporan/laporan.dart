import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedDateRange = 'Pilih Tanggal';

  void _showDateRangePicker() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hari Ini'),
              onTap: () {
                setState(() {
                  selectedDateRange =
                      '${dateFormat.format(now)} - ${dateFormat.format(now)}';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Kemarin'),
              onTap: () {
                final yesterday = now.subtract(const Duration(days: 1));
                setState(() {
                  selectedDateRange =
                      '${dateFormat.format(yesterday)} - ${dateFormat.format(yesterday)}';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1 Minggu'),
              onTap: () {
                final oneWeekAgo = now.subtract(const Duration(days: 7));
                setState(() {
                  selectedDateRange =
                      '${dateFormat.format(oneWeekAgo)} - ${dateFormat.format(now)}';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1 Bulan'),
              onTap: () {
                final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
                setState(() {
                  selectedDateRange =
                      '${dateFormat.format(oneMonthAgo)} - ${dateFormat.format(now)}';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Beranda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20, width: null),
            GestureDetector(
              onTap: _showDateRangePicker,
              child: Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  selectedDateRange,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

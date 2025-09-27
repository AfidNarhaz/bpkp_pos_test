import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:bpkp_pos_test/view/pembelian/add_pembelian.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pembelian extends StatefulWidget {
  const Pembelian({super.key});

  @override
  State<Pembelian> createState() => _PembelianState();
}

class _PembelianState extends State<Pembelian> {
  String selectedDateRange = 'Pilih Tanggal';
  String comparisonDateRange = '';
  DateTime? startDate;
  DateTime? endDate;
  List<Produk> produkList = [];
  List<Produk> filteredProdukList = [];
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembelian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Total Pembelian: 0'),
              ],
            ),
            SizedBox(height: 10),
            DateRangePickerWidget(
              onDateRangeChanged: (start, end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  selectedDateRange =
                      '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                  // Update comparisonDateRange jika perlu
                });
              },
            ),
            SizedBox(height: 10),
            ListTile()
          ],
        ),
      ),
      floatingActionButton: _buildFabByTab(),
    );
  }

  Widget? _buildFabByTab() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPembelian(),
          ),
        );
      },
      tooltip: 'Tambah Produk',
      child: const Icon(Icons.add),
    );
  }
}

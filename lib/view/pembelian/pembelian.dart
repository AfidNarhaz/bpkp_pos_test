import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:bpkp_pos_test/view/pembelian/add_pembelian.dart';
import 'package:bpkp_pos_test/view/pembelian/detail_pembelian.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pembelian extends StatefulWidget {
  const Pembelian({super.key});

  @override
  State<Pembelian> createState() => _PembelianState();
}

class _PembelianState extends State<Pembelian> {
  String selectedDateRange = 'Pilih Tanggal';
  DateTime? startDate;
  DateTime? endDate;

  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>>? _fetchListPembelian;

  @override
  void initState() {
    super.initState();
    loadPembelian();
  }

  void loadPembelian() {
    setState(() {
      _fetchListPembelian = dbHelper.getListPembelian(
        startDate: startDate,
        endDate: endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembelian')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [Text('Total Pembelian: 0')]),
            SizedBox(height: 10),
            DateRangePickerWidget(
              onDateRangeChanged: (start, end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  selectedDateRange =
                      '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                });
                loadPembelian();
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: _fetchListPembelian,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return Center(child: Text('Data pembelian kosong'));
                    }
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              item['code'] ?? '-',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Supplier: ${item['supplier'] ?? '-'}\n'
                              'Tanggal: ${item['tanggal'] ?? '-'}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPembelian(item: item),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFabByTab(),
    );
  }

  Widget _buildFabByTab() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPembelian(),
          ),
        );

        if (result == true) {
          loadPembelian(); // Refresh after adding
        }
      },
      tooltip: 'Tambah Produk',
      child: const Icon(Icons.add),
    );
  }
}

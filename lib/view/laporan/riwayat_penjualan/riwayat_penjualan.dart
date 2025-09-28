import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:bpkp_pos_test/view/laporan/riwayat_penjualan/detail_riwayat_penjualan.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/laporan/drawer.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class RiwayatPenjualanPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const RiwayatPenjualanPage({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<RiwayatPenjualanPage> createState() => _RiwayatPenjualanPageState();
}

class _RiwayatPenjualanPageState extends State<RiwayatPenjualanPage> {
  late DateTime startDate;
  late DateTime endDate;

  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _fetchListPenjualan;

  final logger = Logger();

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
    loadPenjualan();
  }

  void loadPenjualan() {
    setState(() {
      _fetchListPenjualan = dbHelper.getListPenjualan(
        startDate: startDate,
        endDate: endDate,
      );
    });
    logger.i('Future for penjualan loaded: $_fetchListPenjualan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Penjualan',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFED6EA0), Color(0xFFFFA99F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaksi',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 8),
                      Text('2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Penjualan',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 8),
                      Text('Rp40.000',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text('Kamis, 25 September 2025',
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            //     Text('Rp40.000',
            //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            //   ],
            // ),
            // SizedBox(height: 16),

            Expanded(
              child: FutureBuilder(
                future: _fetchListPenjualan,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final list = snapshot.data ?? [];

                    // Print the data here
                    logger.i('List of penjualan: $list');

                    if (list.isEmpty) {
                      return Center(child: Text('Data penjualan kosong'));
                    }

                    return ListView.builder(
                      itemCount:
                          list.length + 1, // +1 untuk item keterangan di bawah
                      itemBuilder: (context, index) {
                        if (index == list.length) {
                          // Ini item terakhir: tampilkan keterangan
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Sudah menampilkan semua data.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          );
                        }

                        // Item transaksi biasa
                        final item = list[index];
                        final formatter = NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp');
                        DateTime tanggal = DateTime.parse(item['tanggal']);
                        final jam =
                            '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';

                        return _TransaksiItem(
                          nominal: formatter.format(item['total_transaksi']),
                          kode: item['noInvoice'],
                          status: 'Lunas',
                          jam: jam,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailRiwayatPenjualanPage(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TransaksiItem extends StatelessWidget {
  final String nominal;
  final String kode;
  final String status;
  final String jam;
  final VoidCallback? onTap; // Tambahkan callback

  const _TransaksiItem({
    required this.nominal,
    required this.kode,
    required this.status,
    required this.jam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Tambahkan onTap
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.grey, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nominal,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(kode, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              status,
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Text(jam, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

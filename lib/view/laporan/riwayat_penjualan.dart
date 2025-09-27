import 'package:bpkp_pos_test/view/colors.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/laporan/drawer.dart';

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

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Penjualan',
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
            // Date Range Picker
            DateRangePickerWidget(
              onDateRangeChanged: (start, end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                });
              },
            ),
            SizedBox(height: 16),

            // Kartu Ringkasan
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

            // Date & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kamis, 25 September 2025',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rp40.000',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            SizedBox(height: 16),

            // List Transaksi
            Column(
              children: [
                _TransaksiItem(
                  nominal: 'Rp10.000',
                  kode: '468156ND',
                  status: 'Lunas',
                  jam: '15:41',
                ),
                SizedBox(height: 12),
                _TransaksiItem(
                  nominal: 'Rp30.000',
                  kode: '46815UBZ',
                  status: 'Lunas',
                  jam: '15:39',
                ),
              ],
            ),
            SizedBox(height: 16),

            // Ujung List
            Center(
              child: Text(
                'Sudah menampilkan semua data.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  const _TransaksiItem({
    required this.nominal,
    required this.kode,
    required this.status,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.receipt_long, color: Colors.grey, size: 32),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nominal,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 12),
        Text(jam, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

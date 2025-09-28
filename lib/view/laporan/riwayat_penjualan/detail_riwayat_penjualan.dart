import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayatPenjualanPage extends StatefulWidget {
  const DetailRiwayatPenjualanPage({
    super.key,
    required this.noInvoice,
    required this.tanggal,
  });

  final String noInvoice;
  final String tanggal;

  @override
  State<DetailRiwayatPenjualanPage> createState() =>
      _DetailRiwayatPenjualanPageState();
}

class _DetailRiwayatPenjualanPageState
    extends State<DetailRiwayatPenjualanPage> {
  final dbHelper = DatabaseHelper();

  late Future<List<Map<String, dynamic>>>? _fetchDetailBarang;

  @override
  void initState() {
    super.initState();
    _loadDetailBarang(widget.noInvoice);
  }

  void _loadDetailBarang(noInvoice) {
    setState(() {
      _fetchDetailBarang = dbHelper.getDetailBarangPenjualan(noInvoice);
    });
  }

  String _formatHarga(double harga) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 2);
    return format.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              'Detail Transaksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            // Email & Kirim Struk
            TextField(
              decoration: InputDecoration(
                hintText: 'Masukan Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text('Kirim Struk'),
              ),
            ),
            SizedBox(height: 20),

            // Logo & Nama Usaha
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/Splash.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'BPKP POS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Pusat',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Detail Pembelian
            Text(
              'Detail Pembelian',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kasir: Difa'),
                Text(widget.tanggal),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Invoice: ${widget.noInvoice}'),
                Text('Tunai'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pelanggan: -'),
                Text('Lunas'),
              ],
            ),
            Divider(height: 24),

            FutureBuilder(
                future: _fetchDetailBarang,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada barang yang dibeli.'));
                  } else {
                    final detailBarang = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: detailBarang.length,
                        itemBuilder: (context, index) {
                          var barang = detailBarang[index];
                          return _produkItem(
                            barang['nama'],
                            'x${barang['jumlah']} @${_formatHarga(barang['hargaJual'])}',
                            _formatHarga(barang['totalHarga']),
                          );
                        },
                      ),
                    );
                  }
                }),
            Divider(height: 24),

            // Tombol Tutup
            SizedBox(height: 32), // Ganti Spacer() dengan SizedBox
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _produkItem(String nama, String qty, String harga) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(qty, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          Text(harga, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

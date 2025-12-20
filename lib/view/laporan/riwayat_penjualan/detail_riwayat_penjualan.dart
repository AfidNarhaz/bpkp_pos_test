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

  void _loadDetailBarang(String noInvoice) {
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
      body: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),

              // Logo & Nama Usaha
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Splash.png',
                      width: 100,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BPKP POS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Jl. Bypass KM 14, Sungai Sapih, Kota Padang',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail Pembelian
              const Text(
                'Detail Pembelian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kasir: Difa'),
                  Text(widget.tanggal),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice: ${widget.noInvoice}'),
                  const Text('Tunai'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Pelanggan: -'),
                  Text('Lunas'),
                ],
              ),
              const Divider(height: 24),

              FutureBuilder(
                future: _fetchDetailBarang,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada barang yang dibeli.'));
                  } else {
                    final detailBarang = snapshot.data!;

                    // Hitung subtotal & total produk
                    double subtotal = 0;
                    int totalProduk = 0;

                    for (var barang in detailBarang) {
                      subtotal += (barang['totalHarga'] as num).toDouble();
                      totalProduk += (barang['jumlah'] as num).toInt();
                    }

                    double diterima = subtotal;
                    double kembalian = diterima - subtotal;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Daftar produk
                        ...detailBarang.map((barang) {
                          return _produkItem(
                            barang['nama'],
                            'x${barang['jumlah']} @${_formatHarga(barang['hargaJual'])}',
                            _formatHarga(barang['totalHarga']),
                          );
                        }),

                        const Divider(height: 24),

                        // Subtotal
                        _summaryItem("Subtotal", _formatHarga(subtotal)),

                        const SizedBox(height: 4),

                        // Total Produk
                        _summaryItem(
                          "Total ($totalProduk Produk)",
                          _formatHarga(subtotal),
                          isBold: true,
                        ),

                        const Divider(height: 24),

                        // Diterima
                        _summaryItem("Diterima", _formatHarga(diterima)),

                        // Kembalian
                        _summaryItem("Kembalian", _formatHarga(kembalian)),
                      ],
                    );
                  }
                },
              ),
              const Divider(height: 24),

              // Tombol Tutup
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
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
              Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(qty, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          Text(harga, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper widget di bawah kelas state
  Widget _summaryItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

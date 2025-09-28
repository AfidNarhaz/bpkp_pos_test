import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class DetailRiwayatPenjualanPage extends StatelessWidget {
  const DetailRiwayatPenjualanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
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
                  Text('25 September 2025, 15:39'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No. Struk: #46815UBZ'),
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

              // List Produk
              _produkItem('Autan', 'x1 @10.000', '10.000'),
              _produkItem(
                  'Kapal Api Special Mix SST 25g', 'x1 @20.000', '20.000'),
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

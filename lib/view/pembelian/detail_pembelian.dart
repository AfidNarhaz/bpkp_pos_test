import 'package:flutter/material.dart';

class DetailPembelian extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailPembelian({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Contoh data dummy, ganti dengan data dari item jika sudah ada
    final penerima = {
      'nama_outlet': item['nama_outlet'] ?? 'Pusat',
      'no_hp': item['no_hp'] ?? '6289998184858',
      'alamat': item['alamat'] ?? 'Jl. Merdeka No. 123, Jakarta',
      'catatan': item['catatan'] ?? '-',
    };

    final informasi = {
      'status': item['status'] ?? 'Selesai',
      'no_order': item['code'] ?? '-',
      'tanggal': item['tanggal'] ?? '-',
      'dibuat_oleh': item['dibuat_oleh'] ?? 'Difa',
      'email': item['email'] ?? 'difazahran@gmail.com',
      'nama_outlet': item['nama_outlet'] ?? 'Pusat',
      'no_hp': item['no_hp'] ?? '6289998184858',
    };

    final aktivitas = [
      {
        'waktu': '26 Sep 2025, 14:33',
        'oleh': 'Difa',
        'order': item['code'] ?? '-',
        'status': 'Order Diproses',
      },
      {
        'waktu': '26 Sep 2025, 07:33',
        'oleh': 'Difa',
        'order': item['code'] ?? '-',
        'status': 'Selesai',
      },
    ];

    final rincian = [
      {'produk': 'Autan', 'harga': 10000},
      {'produk': 'Kapal Api Special Mix SST 25g', 'harga': 100000},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembelian'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Penerima
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Penerima',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    _infoRow('Nama Outlet', penerima['nama_outlet']),
                    _infoRow('No.HP', penerima['no_hp']),
                    _infoRow('Alamat Outlet', penerima['alamat']),
                    _infoRow('Catatan', penerima['catatan']),
                  ],
                ),
              ),
            ),
            // Section Informasi Pembelian
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pembelian',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status Pembelian',
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            informasi['status'],
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoRow('No. Order', informasi['no_order']),
                    _infoRow('Dibuat Tanggal', informasi['tanggal']),
                    _infoRow('Dibuat Oleh', informasi['dibuat_oleh']),
                    _infoRow('Email', informasi['email']),
                    _infoRow('Nama Outlet', informasi['nama_outlet']),
                    _infoRow('Nomor Telepon', informasi['no_hp']),
                  ],
                ),
              ),
            ),
            // Section Aktivitas Pembelian
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aktifitas Pembelian',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    ...aktivitas.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.red, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pada Tanggal ${a['waktu']} oleh ${a['oleh']}, #${a['order']} ${a['status']}.',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            // Section Rincian Pembelian
            const Text('Rincian Pembelian',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Produk',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: rincian.map((r) {
                return ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                  title: Text(
                    '${r['produk']}\nRp${_formatRupiah(r['harga'] as int?)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  children: [
                    Container(
                        color: const Color(0xFFF8F8F8),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow(
                              'Jumlah Pembelian',
                              r['jumlah']?.toString() ?? '-',
                              textColor: Colors.black,
                            ),
                            _detailRow(
                              'Grade',
                              r['grade']?.toString() ?? '-',
                              textColor: Colors.black,
                            ),
                            _detailRow(
                              'Satuan Unit',
                              (r['satuan'] ?? '-').toString(),
                              textColor: Colors.black,
                            ),
                            _detailRow(
                              'Harga Beli Satuan',
                              _formatRupiah(r['harga_beli_satuan'] as int?),
                              textColor: Colors.black,
                            ),
                          ],
                        )),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  static String _formatRupiah(int? value) {
    if (value == null) return '';
    return value
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')
        .replaceAll(',', '.');
  }

  Widget _detailRow(String label, String value,
      {Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: textColor))),
        ],
      ),
    );
  }
}

import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:flutter/material.dart';

class DetailPembelian extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailPembelian({super.key, required this.item});

  @override
  State<DetailPembelian> createState() => _DetailPembelianState();

  static String _formatRupiah(int? value) {
    if (value == null) return '';
    return value
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')
        .replaceAll(',', '.');
  }
}

class _DetailPembelianState extends State<DetailPembelian> {
  final dbHelper = DatabaseHelper();

  late Future<List<Map<String, dynamic>>>? _fetchDetailBarang;

  @override
  void initState() {
    super.initState();
    _loadDetailBarang(widget.item['code']);
  }

  void _loadDetailBarang(String code) {
    setState(() {
      _fetchDetailBarang = dbHelper.getDetailBarangPembelian(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    final informasi = {
      'status': widget.item['status'] ?? 'Selesai',
      'no_order': widget.item['code'] ?? '-',
      'tanggal': widget.item['tanggal'] ?? '-',
      'dibuat_oleh': widget.item['dibuat_oleh'] ?? 'Difa',
      'email': widget.item['email'] ?? 'difazahran@gmail.com',
      'no_hp': widget.item['no_hp'] ?? '6289998184858',
    };

    // final aktivitas = [
    //   {
    //     'waktu': '26 Sep 2025, 14:33',
    //     'oleh': 'Difa',
    //     'order': widget.item['code'] ?? '-',
    //     'status': 'Order Diproses',
    //   },
    //   {
    //     'waktu': '26 Sep 2025, 07:33',
    //     'oleh': 'Difa',
    //     'order': widget.item['code'] ?? '-',
    //     'status': 'Selesai',
    //   },
    // ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembelian'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDetailBarang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final rincian = snapshot.data!;
          print(rincian);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Pembelian',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
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
                        _infoRow('Ref No.', informasi['no_order']),
                        _infoRow('Dibuat Tanggal', informasi['tanggal']),
                        _infoRow('Dibuat Oleh', informasi['dibuat_oleh']),
                        _infoRow('Email', informasi['email']),
                        _infoRow('Nomor Telepon', informasi['no_hp']),
                      ],
                    ),
                  ),
                ),

                // // Section Aktivitas Pembelian
                // Card(
                //   margin: const EdgeInsets.only(bottom: 16),
                //   child: Padding(
                //     padding: const EdgeInsets.all(16),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const Text('Aktifitas Pembelian',
                //             style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.black)),
                //         const SizedBox(height: 8),
                //         ...aktivitas.map((a) => Padding(
                //               padding: const EdgeInsets.only(bottom: 8),
                //               child: Row(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   const Icon(Icons.circle,
                //                       color: Colors.red, size: 14),
                //                   const SizedBox(width: 8),
                //                   Expanded(
                //                     child: Text(
                //                       'Pada Tanggal ${a['waktu']} oleh ${a['oleh']}, #${a['order']} ${a['status']}.',
                //                       style: const TextStyle(
                //                           fontSize: 14, color: Colors.black),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             )),
                //       ],
                //     ),
                //   ),
                // ),

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
                        '${r['nama']}\nRp${DetailPembelian._formatRupiah((r['harga_satuan'] as num).toDouble().round() * (r['jumlah'] as int?)!)}',
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
                                'Satuan Unit',
                                (r['satuanJual'] ?? '-').toString(),
                                textColor: Colors.black,
                              ),
                              _detailRow(
                                'Harga Beli Satuan',
                                DetailPembelian._formatRupiah(
                                    r['hargaJual'].toDouble().round()),
                                textColor: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
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

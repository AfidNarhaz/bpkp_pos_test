import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class DetailKeranjangPage extends StatefulWidget {
  final Map<String, dynamic> produk;
  final Function(Map<String, dynamic>)? onUpdate; // Tambahkan ini

  const DetailKeranjangPage({super.key, required this.produk, this.onUpdate});

  @override
  State<DetailKeranjangPage> createState() => _DetailKeranjangPageState();
}

class _DetailKeranjangPageState extends State<DetailKeranjangPage> {
  late int qty;
  late int stok;
  late int hargaJual;
  late String satuan;
  final TextEditingController _hargaNegoController =
      TextEditingController(); // Tambah controller

  @override
  void dispose() {
    _hargaNegoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    qty = (widget.produk['qty'] ?? 1).toInt();
    stok = (widget.produk['stok'] ?? 0).toInt();
    hargaJual = (widget.produk['hargaJual'] ?? 0).toInt();
    satuan = widget.produk['satuan'] ?? '';
    // Tambahkan ini:
    // Cek apakah ada harga nego di produk keranjang
    final hargaNego = widget.produk['hargaNego'];
    if (hargaNego != null && hargaNego > 0) {
      _hargaNegoController.text =
          'Rp${NumberFormat('#,###', 'id_ID').format(hargaNego)}';
    } else {
      _hargaNegoController.text = '';
    }
  }

  int get total => qty * hargaJual;

  void tambahQty() {
    setState(() {
      if (stok > 0) {
        qty += 1;
        stok -= 1;
      }
    });
  }

  void kurangQty() {
    setState(() {
      if (qty > 1) {
        qty -= 1;
        stok += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produk['nama'] ?? 'Detail Produk',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Harga',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency.format(hargaJual),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stok',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$stok $satuan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatCurrency.format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah Barang:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: kurangQty,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '$qty',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: tambahQty,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Tambahan Harga Nego
              const SizedBox(height: 16),
              const Text(
                'Harga Nego',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _hargaNegoController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyInputFormatter(
                    leadingSymbol: 'Rp',
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 0,
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Masukkan Harga Nego',
                  border: const OutlineInputBorder(),
                  suffixIcon: _hargaNegoController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _hargaNegoController.clear();
                              hargaJual =
                                  (widget.produk['hargaJual'] ?? 0).toInt();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      // Tambahan tombol di bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black, // warna text jadi hitam
                ),
                onPressed: () {
                  // Logika hapus produk: kembali dengan flag deleted
                  Navigator.pop(context, {'deleted': true});
                },
                child: const Text(
                  'Hapus Produk',
                  style: TextStyle(color: Colors.black), // pastikan text hitam
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ganti warna background tombol
                  foregroundColor: Colors.white, // ganti warna teks tombol
                ),
                onPressed: () {
                  final negoText = toNumericString(_hargaNegoController.text);
                  int hargaBaru = (widget.produk['hargaJual'] ?? 0).toInt();
                  int? hargaNego;
                  if (negoText.isNotEmpty) {
                    hargaNego = int.parse(negoText);
                    hargaBaru = hargaNego;
                  }
                  final updatedProduk = {
                    ...widget.produk,
                    'qty': qty,
                    'hargaJual': hargaBaru,
                    'total': qty * hargaBaru,
                  };
                  if (hargaNego != null) {
                    updatedProduk['hargaNego'] = hargaNego;
                  } else {
                    updatedProduk
                        .remove('hargaNego'); // Hapus hargaNego jika kosong
                  }
                  if (widget.onUpdate != null) {
                    widget.onUpdate!(updatedProduk);
                  }
                  Navigator.pop(context, updatedProduk);
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white), // pastikan teks putih
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

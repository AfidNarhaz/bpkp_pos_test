import 'package:flutter/material.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  TambahProdukPageState createState() => TambahProdukPageState();
}

class TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  bool isFavorit = false;

  // Placeholder untuk gambar
  String? _imagePath;

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _merekController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  void _pickImage() {
    setState(() {
      _imagePath = 'assets/sample_image.png'; // Placeholder untuk gambar
    });
  }

  void _hapusGambar() {
    setState(() {
      _imagePath = null;
    });
  }

  void _simpanProduk() {
    if (_namaController.text.isNotEmpty &&
        _hargaController.text.isNotEmpty &&
        _merekController.text.isNotEmpty &&
        _kategoriController.text.isNotEmpty) {
      final newProduk = {
        'nama': _namaController.text,
        'harga': _hargaController.text,
        'merek': _merekController.text,
        'kategori': _kategoriController.text,
        'favorit': isFavorit,
      };

      Navigator.pop(context, newProduk);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua field terlebih dahulu!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _imagePath != null
                  ? Column(
                      children: [
                        Image.asset(
                          _imagePath!,
                          width: 100,
                          height: 100,
                        ),
                        TextButton(
                          onPressed: _hapusGambar,
                          child: const Text('Hapus Gambar'),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: _pickImage,
                      child: const Text('Tambah Gambar'),
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Jual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _merekController,
              decoration: const InputDecoration(
                labelText: 'Merek',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _kategoriController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Favorit:'),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isFavorit,
                  onChanged: (value) {
                    setState(() {
                      isFavorit = value as bool;
                    });
                  },
                ),
                const Text('Ya'),
                Radio(
                  value: false,
                  groupValue: isFavorit,
                  onChanged: (value) {
                    setState(() {
                      isFavorit = value as bool;
                    });
                  },
                ),
                const Text('Tidak'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simpanProduk,
              child: const Text('Simpan Produk'),
            ),
          ],
        ),
      ),
    );
  }
}

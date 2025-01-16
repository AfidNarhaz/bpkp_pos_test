import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';

class TambahPegawaiPage extends StatefulWidget {
  final Product? produk;

  const TambahPegawaiPage({super.key, this.produk});

  @override
  TambahPegawaiPageState createState() => TambahPegawaiPageState();
}

class TambahPegawaiPageState extends State<TambahPegawaiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _namaController.text = widget.produk!.nama;
      _brandController.text = widget.produk!.merek;
      _categoryController.text = widget.produk!.kategori;
      _priceController.text = widget.produk!.hargaJual.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama produk';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Merek Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan merek produk';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori Produk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan kategori produk';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga Produk'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan harga produk';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'nama': _namaController.text,
                      'brand': _brandController.text,
                      'category': _categoryController.text,
                      'price': _priceController.text,
                    });
                  }
                },
                child: Text(widget.produk == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

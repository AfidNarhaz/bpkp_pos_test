import 'package:flutter/material.dart';

class AddPembelian extends StatefulWidget {
  const AddPembelian({super.key});

  @override
  State<AddPembelian> createState() => _AddPembelianState();
}

class _AddPembelianState extends State<AddPembelian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pembelian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Pilih Suplier',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextFormField(),
          ],
        ),
      ),
    );
  }
}

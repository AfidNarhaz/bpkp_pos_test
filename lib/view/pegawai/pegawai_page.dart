import 'package:flutter/material.dart';

class PegawaiPage extends StatelessWidget {
  const PegawaiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pegawai'),
      ),
      body: const Center(
        child: Text('Ini adalah page Pegawai'),
      ),
    );
  }
}

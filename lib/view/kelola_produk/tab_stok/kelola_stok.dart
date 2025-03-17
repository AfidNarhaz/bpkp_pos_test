import 'package:flutter/material.dart';

class KelolaStokPage extends StatelessWidget {
  const KelolaStokPage({super.key}); // Added key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Stok'),
      ),
      body: Center(
        child: const Text('Kelola Stok Page Content'),
      ),
    );
  }
}

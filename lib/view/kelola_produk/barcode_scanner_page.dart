import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatelessWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerPage({super.key, required this.onBarcodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Barcode'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final String code = barcodes.first.rawValue ?? 'Unknown';
            onBarcodeScanned(code);
            Navigator.pop(
                context); // Kembali ke page sebelumnya setelah barcode berhasil discan
          }
        },
      ),
    );
  }
}

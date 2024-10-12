import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerPage({super.key, required this.onBarcodeScanned});

  @override
  BarcodeScannerPageState createState() => BarcodeScannerPageState();
}

class BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanningCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Barcode'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          if (_isScanningCompleted) return;

          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final String code = barcodes.first.rawValue ?? 'Unknown';

            if (code != 'Unknown') {
              // Panggil callback untuk mengirim barcode yang dipindai
              widget.onBarcodeScanned(code);

              // Set status untuk menandakan scan selesai
              setState(() {
                _isScanningCompleted = true;
              });
            } else {
              // Jika barcode tidak valid, tampilkan pesan error, pastikan mounted
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Barcode tidak valid. Coba lagi.')),
                );
              }
            }
          }
        },
      ),
    );
  }
}

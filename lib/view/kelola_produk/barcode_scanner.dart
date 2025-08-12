import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _isScanningCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan Barcode'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          if (_isScanningCompleted) return;
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null && code.isNotEmpty) {
              setState(() => _isScanningCompleted = true);
              Navigator.pop(context, code);
            } else {
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

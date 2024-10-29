import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ManualTab extends StatefulWidget {
  const ManualTab({super.key});

  @override
  ManualTabState createState() => ManualTabState();
}

class ManualTabState extends State<ManualTab> {
  String displayText = 'Rp0'; // Menampilkan total sementara
  double total = 0;

  // Fungsi untuk menambahkan angka
  void _onButtonPressed(String value) {
    setState(() {
      if (displayText == 'Rp0') {
        displayText = 'Rp$value';
      } else {
        displayText += value;
      }
      total = double.parse(displayText.replaceAll('Rp', ''));
    });
  }

  // Fungsi untuk hapus satu karakter
  void _onDelete() {
    setState(() {
      if (displayText.length > 3) {
        displayText = displayText.substring(0, displayText.length - 1);
      } else {
        displayText = 'Rp0';
      }
    });
  }

  // Fungsi untuk membersihkan kalkulator
  void _onClear() {
    setState(() {
      displayText = 'Rp0';
      total = 0;
    });
  }

  // Fungsi untuk menambah produk ke keranjang
  void _onAddToCart() {
    // Tambahkan logika untuk menambah produk ke keranjang
    Logger('Produk ditambahkan ke keranjang: $total');
  }

  // Fungsi untuk menagih produk
  void _onTagih() {
    // Tambahkan logika untuk menagih produk
    Logger('Menagih produk dengan total: $total');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bagian atas untuk menampilkan total
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[200],
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 36), // Ukuran teks lebih kecil
              ),
            ),
          ),
        ),
        // Tambahkan jarak antara container total dan kalkulator
        const SizedBox(
            height: 10), // Memberi jarak antara container dan kalkulator

        // Bagian kalkulator
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.0, // Tombol berbentuk persegi
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildCalcButton('1'),
                _buildCalcButton('2'),
                _buildCalcButton('3'),
                _buildDeleteButton(), // Tombol delete
                _buildCalcButton('4'),
                _buildCalcButton('5'),
                _buildCalcButton('6'),
                _buildCartButton(), // Tombol keranjang dengan proporsi lebih panjang
                _buildCalcButton('7'),
                _buildCalcButton('8'),
                _buildCalcButton('9'),
                _buildEmptyButton(), // Kosong, bisa diisi fungsi lain
                _buildCalcButton('0'),
                _buildCalcButton('000'), // Tombol 000 sekarang akan terlihat
                _buildClearButton(), // Tombol C untuk clear
              ],
            ),
          ),
        ),
        // Tombol Tagih di bagian bawah
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _onTagih,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Tagih = $displayText',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Fungsi untuk membuat tombol kalkulator persegi dengan teks lebih kecil
  Widget _buildCalcButton(String label) {
    return ElevatedButton(
      onPressed: () {
        _onButtonPressed(label);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(
            8.0), // Padding lebih kecil agar ukuran tombol lebih pas
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Tombol persegi
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 18)), // Ukuran teks lebih kecil
    );
  }

  // Tombol delete
  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _onDelete,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Tombol persegi
        ),
      ),
      child: const Icon(Icons.backspace),
    );
  }

  // Tombol keranjang memanjang ke bawah
  Widget _buildCartButton() {
    return ElevatedButton(
      onPressed: _onAddToCart,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 20), // Memanjangkan tombol ke bawah
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Tombol persegi panjang
        ),
      ),
      child: const Icon(Icons.shopping_cart),
    );
  }

  // Tombol kosong
  Widget _buildEmptyButton() {
    return const SizedBox.shrink();
  }

  // Tombol clear (C)
  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: _onClear,
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Tombol persegi
        ),
      ),
      child: const Text('C',
          style: TextStyle(fontSize: 18)), // Ukuran teks lebih kecil
    );
  }
}

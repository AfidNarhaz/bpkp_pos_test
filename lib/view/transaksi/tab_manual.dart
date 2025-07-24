import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManualTab extends StatefulWidget {
  const ManualTab({super.key});

  @override
  ManualTabState createState() => ManualTabState();
}

class ManualTabState extends State<ManualTab> {
  String displayText = 'Rp0';
  double total = 0;
  final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

  void _onButtonPressed(String value) {
    setState(() {
      // Batasi maksimal 20 karakter
      if (displayText.length >= 17) return;
      if (displayText == 'Rp0') {
        displayText = 'Rp$value';
      } else {
        displayText += value;
      }
      total = double.tryParse(
              displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
          0;
      displayText = 'Rp${currencyFormatter.format(total)}';
    });
  }

  void _onDelete() {
    setState(() {
      if (displayText.length > 3) {
        displayText = displayText.substring(0, displayText.length - 1);
        total = double.tryParse(
                displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
            0;
        displayText =
            total > 0 ? 'Rp${currencyFormatter.format(total)}' : 'Rp0';
      } else {
        displayText = 'Rp0';
      }
    });
  }

  void _onClear() {
    setState(() {
      displayText = 'Rp0';
      total = 0;
    });
  }

  void _onAddToCart() {
    debugPrint('Produk ditambahkan ke keranjang: $total');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Ditambahkan ke keranjang: Rp${currencyFormatter.format(total)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[200],
          height: 120,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(16),
          child: Text(
            displayText,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Tombol Angka
              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonCount = 12;
                    final crossAxisCount = 3;
                    final spacing = 8.0;
                    final totalSpacing = spacing * (crossAxisCount - 1);
                    final buttonWidth =
                        (constraints.maxWidth - totalSpacing) / crossAxisCount;
                    final buttonHeight = buttonWidth; // biar kotak

                    final labels = [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '0',
                      '000',
                      'C'
                    ];

                    return GridView.builder(
                      itemCount: buttonCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: buttonWidth / buttonHeight,
                      ),
                      padding: const EdgeInsets.all(8),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final label = labels[index];
                        return ElevatedButton(
                          onPressed: () {
                            if (label == 'C') {
                              _onClear();
                            } else {
                              _onButtonPressed(label);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              Text(label, style: const TextStyle(fontSize: 18)),
                        );
                      },
                    );
                  },
                ),
              ),

              // Tombol Aksi (Backspace dan Checkout)
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol backspace
                      AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          onPressed: _onDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Icon(Icons.backspace, color: Colors.black),
                        ),
                      ),

                      // Tombol checkout
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart,
                                  size: 32, color: Colors.black),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

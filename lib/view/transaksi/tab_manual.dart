// import 'package:bpkp_pos_test/helper/min_child_size.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ManualTab extends StatefulWidget {
//   const ManualTab({super.key});

//   @override
//   ManualTabState createState() => ManualTabState();
// }

// class ManualTabState extends State<ManualTab> {
//   String displayText = 'Rp0';
//   double total = 0;
//   final NumberFormat currencyFormatter = NumberFormat('#,##0', 'id_ID');

//   void _onButtonPressed(String value) {
//     setState(() {
//       if (displayText.length >= 17) return;
//       if (displayText == 'Rp0') {
//         displayText = 'Rp$value';
//       } else {
//         displayText += value;
//       }
//       String numericOnly = displayText.replaceAll(RegExp(r'[^0-9]'), '');
//       total = double.tryParse(numericOnly) ?? 0;
//       displayText = 'Rp${currencyFormatter.format(total)}';
//     });
//   }

//   void _onDelete() {
//     setState(() {
//       if (displayText.length > 3) {
//         displayText = displayText.substring(0, displayText.length - 1);
//         String numericOnly = displayText.replaceAll(RegExp(r'[^0-9]'), '');
//         total = double.tryParse(numericOnly) ?? 0;
//         displayText =
//             total > 0 ? 'Rp${currencyFormatter.format(total)}' : 'Rp0';
//       } else {
//         displayText = 'Rp0';
//       }
//     });
//   }

//   void _onClear() {
//     setState(() {
//       displayText = 'Rp0';
//       total = 0;
//     });
//   }

//   void _onAddToCart() {
//     debugPrint('Produk ditambahkan ke keranjang: $total');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         children: [
//           // Tampilan atas (nominal)
//           Container(
//             color: Colors.grey[200],
//             height: 120,
//             alignment: Alignment.centerRight,
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               displayText,
//               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//           ),

//           // Area tombol kalkulator
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final crossAxisCount = 3;
//                   final spacing = 8.0;
//                   final totalSpacing = spacing * (crossAxisCount - 1);
//                   final buttonWidth =
//                       ((constraints.maxWidth * 0.75 - totalSpacing) /
//                               crossAxisCount)
//                           .clamp(1.0, double.infinity);
//                   // final buttonHeight = buttonWidth;

//                   final labels = [
//                     '1',
//                     '2',
//                     '3',
//                     '4',
//                     '5',
//                     '6',
//                     '7',
//                     '8',
//                     '9',
//                     '0',
//                     '000',
//                     'C'
//                   ];

//                   double calculateChildAspectRatio(BoxConstraints constraints) {
//                     int totalRows = (labels.length / crossAxisCount).ceil();
//                     double availableHeight = constraints.maxHeight;
//                     double totalVerticalSpacing = (totalRows - 1) * spacing;
//                     double effectiveRowHeight =
//                         (availableHeight - totalVerticalSpacing) / totalRows;

//                     if (effectiveRowHeight <= 0) return 1.0; // fallback aman

//                     return buttonWidth / effectiveRowHeight;
//                   }

//                   return Row(
//                     children: [
//                       // Tombol angka
//                       Expanded(
//                         flex: 3,
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                             bottom: MediaQuery.of(context).size.height *
//                                 minChildSize,
//                           ),
//                           child: LayoutBuilder(
//                             builder: (context, constraints) {
//                               // Hitung childAspectRatio secara dinamis
//                               final double dynamicChildAspectRatio =
//                                   calculateChildAspectRatio(constraints);

//                               return GridView.builder(
//                                 itemCount: labels.length,
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: crossAxisCount,
//                                   crossAxisSpacing: spacing,
//                                   mainAxisSpacing: spacing,
//                                   childAspectRatio: dynamicChildAspectRatio,
//                                 ),
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   final label = labels[index];
//                                   return ElevatedButton(
//                                     onPressed: () {
//                                       if (label == 'C') {
//                                         _onClear();
//                                       } else {
//                                         _onButtonPressed(label);
//                                       }
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       padding: EdgeInsets.zero,
//                                       backgroundColor: Colors.white,
//                                       foregroundColor: Colors.black,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: Text(label,
//                                         style: const TextStyle(fontSize: 18)),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ),

//                       // Tombol aksi (hapus & keranjang)
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           children: [
//                             // Backspace
//                             Expanded(
//                               flex: 1,
//                               child: ElevatedButton(
//                                 onPressed: _onDelete,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.grey[300],
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: const Icon(Icons.backspace,
//                                     color: Colors.black),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             // Tambahkan ke keranjang
//                             Expanded(
//                               flex: 4,
//                               child: Padding(
//                                 padding: EdgeInsets.only(
//                                   bottom: MediaQuery.of(context).size.height *
//                                       minChildSize,
//                                   left: 7,
//                                   right: 7,
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed: _onAddToCart,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green[100],
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   child: const Icon(Icons.shopping_cart,
//                                       size: 32, color: Colors.black),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

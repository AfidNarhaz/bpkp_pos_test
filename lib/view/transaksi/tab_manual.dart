// import 'package:bpkp_pos_test/view/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
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
//       if (displayText == 'Rp0') {
//         displayText = 'Rp$value';
//       } else {
//         displayText += value;
//       }
//       total = double.tryParse(
//               displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
//           0;
//       displayText = 'Rp${currencyFormatter.format(total)}';
//     });
//   }

//   void _onDelete() {
//     setState(() {
//       if (displayText.length > 3) {
//         displayText = displayText.substring(0, displayText.length - 1);
//         total = double.tryParse(
//                 displayText.replaceAll('Rp', '').replaceAll('.', '')) ??
//             0;
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
//     Logger('Produk ditambahkan ke keranjang: $total');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Tampilan total
//         Expanded(
//           flex: 2,
//           child: Container(
//             color: Colors.grey[200],
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             alignment: Alignment.centerRight,
//             child: Text(
//               displayText,
//               style: const TextStyle(fontSize: 36),
//             ),
//           ),
//         ),

//         // Kalkulator manual
//         Expanded(
//           flex: 6,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 // Kolom tombol angka (3x4)
//                 Expanded(
//                   flex: 3,
//                   child: Table(
//                     border: TableBorder.all(color: Colors.transparent),
//                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//                     children: [
//                       _buildTableRow(['1', '2', '3']),
//                       _buildTableRow(['4', '5', '6']),
//                       _buildTableRow(['7', '8', '9']),
//                       _buildTableRow(['0', '000', 'C']),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Tombol backspace dan keranjang memanjang
//                 SizedBox(
//                   width: 72,
//                   child: Column(
//                     children: [
//                       Expanded(
//                         flex: 1,
//                         child: Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: _buildIconButton(Icons.backspace, _onDelete),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         flex: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.all(1.0),
//                           child: _buildCartButton(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   TableRow _buildTableRow(List<String> labels) {
//     return TableRow(
//       children: labels.map((label) {
//         if (label == '⌫') {
//           return _buildIconButton(Icons.backspace, _onDelete);
//         } else if (label == '🛒') {
//           return const SizedBox.shrink(); // Empty cell for alignment
//         } else {
//           return Padding(
//             padding: const EdgeInsets.all(4),
//             child: SizedBox(
//               height: 64,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (label == 'C') {
//                     _onClear();
//                   } else {
//                     _onButtonPressed(label);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.secondary,
//                   foregroundColor: AppColors.text,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.zero,
//                   ),
//                 ),
//                 child: Text(label, style: const TextStyle(fontSize: 15)),
//               ),
//             ),
//           );
//         }
//       }).toList(),
//     );
//   }

//   Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.text,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.zero,
//         ),
//       ),
//       child: Icon(icon),
//     );
//   }

//   Widget _buildCartButton() {
//     return ElevatedButton(
//       onPressed: _onAddToCart,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.accent,
//         foregroundColor: AppColors.text,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.zero,
//         ),
//       ),
//       child: const Icon(Icons.shopping_cart, size: 30),
//     );
//   }
// }

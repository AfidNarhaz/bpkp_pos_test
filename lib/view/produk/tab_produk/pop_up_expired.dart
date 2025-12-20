import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PopUpExpired {
  static Future<void> showPopUpExpired(
      BuildContext context, Function(String) onDateSelected) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Format tanggal menjadi string
    if (selectedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
      onDateSelected(
          formattedDate); // Mengirim tanggal yang dipilih kembali ke callback
    }
  }
}

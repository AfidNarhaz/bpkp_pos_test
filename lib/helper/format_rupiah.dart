import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatRupiah extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String prefix;

  const FormatRupiah({
    super.key,
    required this.value,
    this.style,
    this.prefix = 'Rp',
  });

  String get formatted {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return '$prefix${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatted,
      style: style,
    );
  }
}

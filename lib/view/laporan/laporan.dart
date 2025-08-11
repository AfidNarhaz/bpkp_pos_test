import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bpkp_pos_test/view/home/home_page.dart';
import 'package:bpkp_pos_test/view/laporan/drawer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String selectedDateRange = 'Pilih Tanggal';
  String comparisonDateRange = ''; // untuk "Dibandingkan ..."
  DateTime? startDate;
  DateTime? endDate;

  void _showDateRangePicker() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    PickerDateRange? selectedRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Preset filter
                  Wrap(
                    spacing: 8,
                    children: [
                      _presetButton("Hari Ini", () {
                        setStateModal(() {
                          selectedRange = PickerDateRange(now, now);
                        });
                      }),
                      _presetButton("Kemarin", () {
                        final yesterday = now.subtract(const Duration(days: 1));
                        setStateModal(() {
                          selectedRange = PickerDateRange(yesterday, yesterday);
                        });
                      }),
                      _presetButton("1 Minggu", () {
                        setStateModal(() {
                          selectedRange = PickerDateRange(
                            now.subtract(const Duration(days: 7)),
                            now,
                          );
                        });
                      }),
                      _presetButton("1 Bulan", () {
                        setStateModal(() {
                          selectedRange = PickerDateRange(
                            DateTime(now.year, now.month - 1, now.day),
                            now,
                          );
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kalender
                  SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange:
                        selectedRange ?? PickerDateRange(now, now),
                    onSelectionChanged: (args) {
                      setStateModal(() {
                        selectedRange = args.value;
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedRange != null) {
                            final start = selectedRange!.startDate!;
                            final end = selectedRange!.endDate ?? start;

                            // Simpan periode utama
                            startDate = start;
                            endDate = end;

                            // Hitung periode pembanding
                            final diffDays = end.difference(start).inDays;
                            final comparisonEnd =
                                start.subtract(const Duration(days: 1));
                            final comparisonStart = comparisonEnd
                                .subtract(Duration(days: diffDays));

                            setState(() {
                              final dateFormat = DateFormat('dd/MM/yyyy');
                              selectedDateRange =
                                  '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                              comparisonDateRange =
                                  '${dateFormat.format(comparisonStart)} - ${dateFormat.format(comparisonEnd)}';
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _presetButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }

  Widget _buildReportCard(String title, String value, String growth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(growth,
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Beranda',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: Drawer(
          child: LaporanDrawer(parentContext: context),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter tanggal
                GestureDetector(
                  onTap: _showDateRangePicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          selectedDateRange,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (comparisonDateRange.isNotEmpty)
                  Text(
                    "Dibandingkan $comparisonDateRange",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 12),

                // Kartu laporan
                _buildReportCard("Total Penjualan", "Rp560.000", "↑ 833,33%"),
                const SizedBox(height: 8),
                _buildReportCard("Total Keuntungan", "Rp447.000", "↑ 893,33%"),
                const SizedBox(height: 8),
                _buildReportCard("Total Transaksi", "12", "↑ 1100,00%"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

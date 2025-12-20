import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:bpkp_pos_test/view/laporan/laporan_widget/date_range_state.dart';

class DateRangePickerWidget extends StatefulWidget {
  final Function(DateTime start, DateTime end) onDateRangeChanged;

  const DateRangePickerWidget({
    super.key,
    required this.onDateRangeChanged,
  });

  @override
  State<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  String selectedDateRange = '';
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    selectedDateRange =
        '${dateFormat.format(GlobalDateRange.startDate)} - ${dateFormat.format(GlobalDateRange.endDate)}';
  }

  void _showPicker() {
    final now = DateTime.now();
    PickerDateRange selectedRange = PickerDateRange(
      GlobalDateRange.startDate,
      GlobalDateRange.endDate,
    );

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
                              now.subtract(const Duration(days: 7)), now);
                        });
                      }),
                      _presetButton("1 Bulan", () {
                        setStateModal(() {
                          selectedRange = PickerDateRange(
                              DateTime(now.year, now.month - 1, now.day), now);
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: selectedRange,
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
                          final start = selectedRange.startDate ?? now;
                          final end = selectedRange.endDate ?? start;

                          GlobalDateRange.setRange(start, end);

                          setState(() {
                            selectedDateRange =
                                '${dateFormat.format(start)} - ${dateFormat.format(end)}';
                          });

                          widget.onDateRangeChanged(start, end);

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
    return OutlinedButton(onPressed: onTap, child: Text(label));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              selectedDateRange,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

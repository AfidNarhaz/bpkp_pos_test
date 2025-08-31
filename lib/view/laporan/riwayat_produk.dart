import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/model/model_history_produk.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:intl/intl.dart';

class RiwayatProdukPage extends StatefulWidget {
  final String namaProduk;
  const RiwayatProdukPage({super.key, required this.namaProduk});

  @override
  State<RiwayatProdukPage> createState() => _RiwayatProdukPageState();
}

class _RiwayatProdukPageState extends State<RiwayatProdukPage> {
  List<HistoryProduk> historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final allHistory = await DatabaseHelper().getAllHistoryProduk();
    setState(() {
      // Filter hanya riwayat produk yang dipilih
      historyList =
          allHistory.where((h) => h.namaProduk == widget.namaProduk).toList();
    });
  }

  String formatWaktu(DateTime waktu) {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(waktu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Produk'),
      ),
      body: historyList.isEmpty
          ? const Center(child: Text('Belum ada riwayat untuk produk ini'))
          : ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final h = historyList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(h.aksi),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Oleh: ${h.user}'),
                        Text('Role: ${h.role}'),
                        Text('Waktu: ${formatWaktu(h.waktu)}'),
                        if (h.detail != null && h.detail!.isNotEmpty)
                          Text('Detail: ${h.detail!}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:bpkp_pos_test/view/kelola_produk/tab_kategori/kategori_dialog.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class KategoriTab extends StatefulWidget {
  const KategoriTab({super.key});

  @override
  KategoriTabState createState() => KategoriTabState();
}

class KategoriTabState extends State<KategoriTab> {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getKategori(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat kategori'));
          }
          final listKategori = snapshot.data ?? [];
          if (listKategori.isNotEmpty) {
            return ListView.builder(
              itemCount: listKategori.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(listKategori[index]['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return KategoriDialog(
                            index: index,
                            listKategori: listKategori,
                            dbHelper: dbHelper,
                            onUpdate: () => setState(() {}),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Belum ada kategori'));
          }
        },
      ),
    );
  }
}

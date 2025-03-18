import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_kategori/kategori_dialog.dart';
import 'package:bpkp_pos_test/view/colors.dart';

class KategoriTab extends StatefulWidget {
  const KategoriTab({super.key});

  @override
  KategoriTabState createState() => KategoriTabState();
}

class KategoriTabState extends State<KategoriTab> {
  List<Map<String, dynamic>> _listKategori = [];
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadKategoriAsync();
  }

  Future<void> _loadKategoriAsync() async {
    final data = await dbHelper.getKategori();
    setState(() {
      _listKategori = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _listKategori.isNotEmpty
          ? ListView.builder(
              itemCount: _listKategori.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_listKategori[index]['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return KategoriDialog(
                            index: index,
                            listKategori: _listKategori,
                            dbHelper: dbHelper,
                            onUpdate: _loadKategoriAsync,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            )
          : const Center(child: Text('Belum ada kategori')),
    );
  }
}

import 'package:bpkp_pos_test/view/pegawai/add_pegawai_page.dart';
import 'package:bpkp_pos_test/view/pegawai/detail_pegawai_page.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  PegawaiPageState createState() => PegawaiPageState();
}

class PegawaiPageState extends State<PegawaiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pegawai',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Pegawai',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pegawai>>(
              future: _databaseHelper.getAllPegawai(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Gagal memuat data pegawai.'));
                }
                final pegawaiList = snapshot.data ?? [];
                final filteredPegawaiList = pegawaiList
                    .where((pegawai) => pegawai.nama
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
                if (filteredPegawaiList.isEmpty) {
                  return const Center(child: Text('Belum ada data pegawai.'));
                }
                return ListView.builder(
                  itemCount: filteredPegawaiList.length,
                  itemBuilder: (context, index) {
                    Pegawai pegawai = filteredPegawaiList[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPegawaiPage(
                                  pegawai: pegawai,
                                  onPegawaiUpdated: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(51),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kiri: Detail pegawai
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Nama: ${pegawai.nama}',
                                          style: TextStyle(fontSize: 18)),
                                      Text('No.HP: ${pegawai.noHp}',
                                          style: TextStyle(fontSize: 16)),
                                      Text('Jabatan: ${pegawai.jabatan}',
                                          style: TextStyle(fontSize: 16)),
                                      Text('Email: ${pegawai.email}',
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                        'Password: ${_maskPassword(pegawai.password)}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                // Kanan: Foto pegawai
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: pegawai.imagePath != null &&
                                          pegawai.imagePath!.isNotEmpty
                                      ? Image.file(
                                          File(pegawai.imagePath!),
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.person,
                                              size: 40, color: Colors.grey),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider, jangan tampilkan di bawah item terakhir
                        if (index != filteredPegawaiList.length - 1)
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            height: 0,
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPegawaiPage(
                onPegawaiAdded: () => setState(() {}),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _maskPassword(String password) {
    if (password.length <= 2) return '*' * password.length;
    return password[0] +
        '*' * (password.length - 2) +
        password[password.length - 1];
  }
}

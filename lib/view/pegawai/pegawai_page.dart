import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/pegawai/tambah_pegawai_page.dart'; // Import the new page

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  PegawaiPageState createState() => PegawaiPageState();
}

class PegawaiPageState extends State<PegawaiPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Pegawai> _pegawaiList = []; // List untuk menyimpan data pegawai
  List<Pegawai> _filteredPegawaiList = []; // List untuk menyimpan hasil filter
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchPegawai(); // Ambil data pegawai saat halaman diinisialisasi
    _searchController
        .addListener(_filterPegawai); // Tambahkan listener untuk search bar
  }

  @override
  void dispose() {
    _searchController.dispose(); // Hapus controller saat widget dihapus
    super.dispose();
  }

  Future<void> _fetchPegawai() async {
    List<Pegawai> pegawai =
        await _databaseHelper.getAllPegawai(); // Ambil semua pegawai
    setState(() {
      _pegawaiList = pegawai; // Simpan data pegawai ke dalam list
      _filteredPegawaiList =
          pegawai; // Inisialisasi list filter dengan semua pegawai
    });
  }

  void _filterPegawai() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPegawaiList = _pegawaiList
          .where((pegawai) => pegawai.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  // Tampilkan data pegawai dalam ListView
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pegawai'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
            child: _filteredPegawaiList.isEmpty
                ? Center(child: Text('Belum ada data pegawai.'))
                : ListView.builder(
                    itemCount: _filteredPegawaiList.length,
                    itemBuilder: (context, index) {
                      Pegawai pegawai = _filteredPegawaiList[index];
                      return GestureDetector(
                        onTap: () {}, // Tampilkan detail pegawai saat ditekan
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(51), // 20% opacity
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama: ${pegawai.nama}',
                                  style: TextStyle(fontSize: 18)),
                              Text('No.HP: ${pegawai.noHp}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Jabatan: ${pegawai.jabatan}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Email: ${pegawai.email}',
                                  style: TextStyle(fontSize: 16)),
                              Text('PIN: ${pegawai.pin}',
                                  style: TextStyle(fontSize: 16)),
                              // if (pegawai.imagePath.isNotEmpty)
                              //   Image.file(File(pegawai.imagePath),
                              // height: 100, width: 100, fit: BoxFit.cover),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPegawaiPage()),
          ); // Navigate to the new page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:io';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  PegawaiPageState createState() => PegawaiPageState();
}

class PegawaiPageState extends State<PegawaiPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  DateTime? _tanggalLahir;
  String? _fotoPath;
  List<Pegawai> _pegawaiList = []; // List untuk menyimpan data pegawai
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchPegawai(); // Ambil data pegawai saat halaman diinisialisasi
  }

  Future<void> _fetchPegawai() async {
    List<Pegawai> pegawai =
        await _databaseHelper.getAllPegawai(); // Ambil semua pegawai
    setState(() {
      _pegawaiList = pegawai; // Simpan data pegawai ke dalam list
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _fotoPath = image.path; // Simpan path foto
      });
    }
  }

  Future<void> _savePegawai() async {
    if (_namaController.text.isNotEmpty &&
        _nikController.text.isNotEmpty &&
        _alamatController.text.isNotEmpty &&
        _tanggalLahir != null &&
        _fotoPath != null) {
      Pegawai pegawai = Pegawai(
        nama: _namaController.text,
        nik: _nikController.text,
        alamat: _alamatController.text,
        tanggalLahir: _tanggalLahir!,
        fotoPath: _fotoPath!,
      );

      await _databaseHelper.insertPegawai(pegawai);
      _clearForm();
      await _fetchPegawai(); // Ambil data pegawai setelah menyimpan

      // Pastikan widget masih terpasang di tree sebelum memanggil ScaffoldMessenger
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pegawai berhasil disimpan!')),
        );
      }
    } else {
      // Pastikan widget masih terpasang di tree sebelum memanggil ScaffoldMessenger
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field!')),
        );
      }
    }
  }

  void _clearForm() {
    _namaController.clear();
    _nikController.clear();
    _alamatController.clear();
    setState(() {
      _tanggalLahir = null;
      _fotoPath = null;
    });
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: _nikController,
                  decoration: const InputDecoration(labelText: 'NIK'),
                ),
                TextField(
                  controller: _alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir',
                    hintText: _tanggalLahir != null
                        ? _tanggalLahir!.toLocal().toString().split(' ')[0]
                        : 'Pilih Tanggal',
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _tanggalLahir ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _tanggalLahir = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                _fotoPath != null
                    ? Image.file(File(_fotoPath!))
                    : const Text('Belum ada foto yang dipilih'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pilih Foto'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup modal
                    _savePegawai(); // Simpan pegawai
                  },
                  child: const Text('Simpan Pegawai'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPegawaiDetail(Pegawai pegawai) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pegawai.nama),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('NIK: ${pegawai.nik}'),
              Text('Alamat: ${pegawai.alamat}'),
              Text(
                  'Tanggal Lahir: ${pegawai.tanggalLahir.toLocal().toString().split(' ')[0]}'),
              if (pegawai.fotoPath.isNotEmpty)
                Image.file(File(pegawai.fotoPath),
                    height: 100, width: 100, fit: BoxFit.cover),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pegawai'),
      ),
      body: _pegawaiList.isEmpty
          ? Center(child: Text('Belum ada data pegawai.'))
          : ListView.builder(
              itemCount: _pegawaiList.length,
              itemBuilder: (context, index) {
                Pegawai pegawai = _pegawaiList[index];
                return GestureDetector(
                  onTap: () => _showPegawaiDetail(
                      pegawai), // Tampilkan detail pegawai saat ditekan
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
                        Text('NIK: ${pegawai.nik}',
                            style: TextStyle(fontSize: 16)),
                        Text('Alamat: ${pegawai.alamat}',
                            style: TextStyle(fontSize: 16)),
                        Text(
                            'Tanggal Lahir: ${pegawai.tanggalLahir.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 16)),
                        if (pegawai.fotoPath.isNotEmpty)
                          Image.file(File(pegawai.fotoPath),
                              height: 100, width: 100, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

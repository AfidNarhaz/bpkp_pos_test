import 'dart:io';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bpkp_pos_test/view/kelola_produk/tab_produk/image_service.dart';

class AddPegawaiPage extends StatefulWidget {
  const AddPegawaiPage({super.key});

  @override
  AddPegawaiPageState createState() => AddPegawaiPageState();
}

class AddPegawaiPageState extends State<AddPegawaiPage> {
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String? _fotoPath;
  File? _image;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _imageService.initDb(); // Inisialisasi database gambar
  }

  Future<void> _initializeServices() async {
    try {
      debugPrint("[INFO] Initializing ImageService and loading data...");
      await _imageService.initDb();

      debugPrint("[INFO] Initialization completed successfully.");
    } catch (e) {
      debugPrint("[ERROR] Failed to initialize services: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      debugPrint("[INFO] Attempting to pick an image...");
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final image = File(pickedFile.path);
        if (mounted) {
          setState(() {
            _image = image;
          });
          debugPrint("[INFO] Image picked and set successfully: ${image.path}");
        }
      } else {
        debugPrint("[WARNING] No image was picked.");
      }
    } on PlatformException catch (e) {
      debugPrint(
          "[ERROR] PlatformException while picking an image: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick an image: ${e.message}')),
        );
      }
    } on FileSystemException catch (e) {
      debugPrint(
          "[ERROR] FileSystemException while picking an image: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save the image: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint("[ERROR] Unexpected error while picking an image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _savePegawai() async {
    if (_formKey.currentState!.validate()) {
      final newPegawai = Pegawai(
          imagePath: _image?.path,
          nama: _namaController.text,
          noHp: _phoneController.text,
          jabatan: _jabatanController.text,
          email: _emailController.text,
          pin: int.parse(_pinController.text));

      await DatabaseHelper()
          .insertPegawai(newPegawai); // Simpan data pegawai ke database

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pegawai berhasil disimpan!')),
        ); // Show a snackbar
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua field!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pegawai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _fotoPath != null
                  ? Image.file(File(_fotoPath!), height: 150, width: 150)
                  : const Text('Belum ada foto yang dipilih'),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pilih Foto'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pegawai',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Handphone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Input Kode Negara Dahulu, Ex: 62123456789',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePegawai,
                child: const Text('Simpan Pegawai'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

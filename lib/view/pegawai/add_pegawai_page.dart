import 'package:bpkp_pos_test/view/produk/tab_produk/image_service.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:bpkp_pos_test/model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AddPegawaiPage extends StatefulWidget {
  const AddPegawaiPage({super.key, this.pegawai, required this.onPegawaiAdded});
  final Pegawai? pegawai;
  final VoidCallback onPegawaiAdded;

  @override
  AddPegawaiPageState createState() => AddPegawaiPageState();
}

class AddPegawaiPageState extends State<AddPegawaiPage> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  } // Hapus controller saat widget dihapus

  @override
  void initState() {
    super.initState();
    _imageService.initDb(); // Inisialisasi database gambar
    _initializeServices(); // Inisialisasi service
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
      // Cek semua field wajib terisi
      if (_namaController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _jabatanController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field wajib diisi!')),
        );
        return;
      }
      final newPegawai = Pegawai(
        imagePath: _image?.path,
        nama: _namaController.text,
        noHp: int.tryParse(_phoneController.text) ?? 0,
        jabatan: _jabatanController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await DatabaseHelper().insertPegawai(newPegawai);

      // Tambahkan ke tabel users untuk login
      final user = User(
        username: _namaController.text,
        password: _passwordController.text,
        role: _jabatanController.text.toLowerCase(), // contoh: 'kasir'
      );
      await DatabaseHelper().insertUser(user);

      if (mounted) {
        widget.onPegawaiAdded();
        Navigator.pop(context, newPegawai);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Pegawai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image Picker
                GestureDetector(
                  onTap: () async {
                    debugPrint("[INFO] Image picker triggered.");
                    try {
                      await _pickImage();
                      if (!mounted) {
                        return; // Cek apakah widget masih dalam tree
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Image picked successfully')),
                        ); // Tampilkan snackbar
                      }
                    } catch (e) {
                      debugPrint("[ERROR] Error picking image: $e");
                      if (!mounted) return; // Cek sebelum menggunakan context

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error picking image: $e')),
                        ); // Tampilkan snackbar
                      }
                    }
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _image == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.black54,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                // Nama Pegawai
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Pegawai',
                ),

                //No.HP Pegawai
                _buildTextField(
                  controller: _phoneController,
                  label: 'No.Handphone',
                  keyboardType: TextInputType.number,
                ),
                const Text(
                  'Input Kode Negara Dahulu, Ex: 62123456789',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                //Jabatan Pegawai
                _buildTextField(
                  controller: _jabatanController,
                  label: 'Jabatan',
                  keyboardType: TextInputType.text,
                ),

                //Email Pegawai
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                // Password Pegawai
                _buildTextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  label: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(12)
                  ], // Limit 12 karakter
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
      ),
    );
  }

  // Fungsi untuk membangun TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false, // Add this parameter
    Widget? suffixIcon, // Change suffixIcon to Widget? to allow custom widgets
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatter,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText, // Use the obscureText parameter
        keyboardType: keyboardType,
        readOnly: readOnly,
        inputFormatters: inputFormatter,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon, // Use the suffixIcon parameter
          filled: true,
          fillColor: Colors.blue[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field tidak boleh kosong';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password minimal 6 karakter';
          }
          if (label == 'Password' && value.length > 12) {
            return 'Password maksimal 12 karakter';
          }
          return null;
        },
      ),
    );
  }
}

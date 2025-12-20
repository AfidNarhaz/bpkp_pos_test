import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:bpkp_pos_test/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DetailPegawaiPage extends StatefulWidget {
  final Pegawai pegawai;
  final VoidCallback onPegawaiUpdated;
  const DetailPegawaiPage(
      {super.key, required this.pegawai, required this.onPegawaiUpdated});

  @override
  State<DetailPegawaiPage> createState() => _DetailPegawaiPageState();
}

class _DetailPegawaiPageState extends State<DetailPegawaiPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _phoneController;
  late TextEditingController _jabatanController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isObscure = true;
  File? _image;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.pegawai.nama);
    _phoneController =
        TextEditingController(text: widget.pegawai.noHp.toString());
    _jabatanController = TextEditingController(text: widget.pegawai.jabatan);
    _emailController = TextEditingController(text: widget.pegawai.email);
    _passwordController = TextEditingController(text: widget.pegawai.password);
    if (widget.pegawai.imagePath != null) {
      _image = File(widget.pegawai.imagePath!);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updatePegawai() async {
    if (_formKey.currentState!.validate()) {
      final updatedPegawai = Pegawai(
        id: widget.pegawai.id,
        imagePath: _image?.path,
        nama: _namaController.text,
        noHp: int.tryParse(_phoneController.text) ?? 0,
        jabatan: _jabatanController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await DatabaseHelper().updatePegawai(updatedPegawai);

      // Update ke tabel users
      final updatedUser = User(
        username: _namaController.text,
        password: _passwordController.text,
        role: _jabatanController.text.toLowerCase(),
      );
      await DatabaseHelper().updateUser(widget.pegawai.nama, updatedUser);

      widget.onPegawaiUpdated();
      Navigator.pop(context, updatedPegawai);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pegawai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image preview
                Container(
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
                const SizedBox(height: 20),
                _buildTextField(
                    controller: _namaController, label: 'Nama Pegawai'),
                _buildTextField(
                    controller: _phoneController,
                    label: 'No.Handphone',
                    keyboardType: TextInputType.number),
                const Text(
                  'Input Kode Negara Dahulu, Ex: 62123456789',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                _buildTextField(
                    controller: _jabatanController, label: 'Jabatan'),
                _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _isObscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatter: [LengthLimitingTextInputFormatter(12)],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updatePegawai,
                  child: const Text('Update Pegawai'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatter,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        inputFormatters: inputFormatter,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
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

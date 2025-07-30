import 'package:bpkp_pos_test/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bpkp_pos_test/view/colors.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscure = true; // Untuk menyembunyikan/menampilkan password
  String? _errorMessage; // Untuk menyimpan pesan error

  void _login() async {
    final username = usernameController.text;
    final password = passwordController.text;
    final user = await DatabaseHelper().getUser(username, password);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user.username);
      await prefs.setString('role', user.role);
      await prefs.setBool('isLoggedIn', true);
      if (!mounted) return;
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (user.role == 'kasir') {
        Navigator.pushReplacementNamed(context, '/transaksi');
      } else {
        setState(() {
          _errorMessage = 'Role pengguna tidak dikenali.';
        });
      }
    } else {
      // print('No user matched'); // Debug log
      setState(() {
        _errorMessage = 'Username atau password salah';
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width > 600 ? 600 : 400;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: SizedBox(
              width: itemWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "P.O.S BPKP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  // Field untuk username vvv
                  SizedBox(
                    width: 300, // Atur lebar (panjang)
                    height: 40, // Atur tinggi (lebar)
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.secondary,
                        hintText: "Username",
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.normal, // Berat huruf normal
                          fontSize: 13, // Atur ukuran huruf hintText
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black, // Warna outline
                            width: 2.0, // Ketebalan outline
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black, // Warna outline ketika enabled
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: AppColors
                                .accent, // Warna outline ketika focused
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Field untuk password dengan ikon show/hide vvv
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText:
                          _isObscure, // Menentukan apakah password tersembunyi
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.secondary,
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.normal, // Berat huruf normal
                          fontSize: 13, // Atur ukuran huruf hintText
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black, // Warna outline
                            width: 2.0, // Ketebalan outline
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black, // Warna outline ketika enabled
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: AppColors
                                .accent, // Warna outline ketika focused
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility
                              : Icons.visibility_off), // Ikon untuk show/hide
                          onPressed: () {
                            setState(() {
                              _isObscure =
                                  !_isObscure; // Toggle antara true/false
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _login,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size(250, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

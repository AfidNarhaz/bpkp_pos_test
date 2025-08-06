import 'dart:convert';
import 'dart:io';

class Pegawai {
  final int? id;
  final String? imagePath;
  final String nama;
  final int noHp;
  final String jabatan;
  final String email;
  final String password;

  Pegawai({
    this.id,
    this.imagePath,
    required this.nama,
    required this.noHp,
    required this.jabatan,
    required this.email,
    required this.password,
  });

  // Konversi dari map (Database ke Pegawai)
  factory Pegawai.fromMap(Map<String, dynamic> map) {
    return Pegawai(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String?,
      nama: map['nama'] as String? ?? '',
      noHp: map['noHp'] as int? ?? 0,
      jabatan: map['jabatan'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  // Konversi ke map (Pegawai ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'nama': nama,
      'noHp': noHp,
      'jabatan': jabatan,
      'email': email,
      'password': password,
    };
  }

  // Save list pegawai ke file
  static Future<void> saveToFile(
      List<Pegawai> pegawaiList, String filePath) async {
    final file = File(filePath);
    final jsonList = pegawaiList.map((pegawai) => pegawai.toMap()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Load list of Pegawai from a file
  static Future<List<Pegawai>> loadFromFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Pegawai.fromMap(json)).toList();
  }

  // Override method toString untuk debugging
  @override
  String toString() {
    return 'Pegawai{id: $id, imagePath: $imagePath, nama: $nama, noHp: $noHp, jabatan: $jabatan, email: $email, password: $password}';
  }
}

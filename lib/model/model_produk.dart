import 'dart:convert';
import 'dart:io';

// Model untuk data produk
class Produk {
  final int? id;
  final String? imagePath;
  String codeProduk;
  String barcode;
  String nama;
  String kategori;
  String merek;
  String tglExpired; // Ubah dari DateTime ke String
  String? satuanBeli;
  String? satuanJual;
  int? isi;
  double hargaBeli;
  double hargaJual;
  int? minStok;
  int? stok;
  bool? sendNotification;

  // Constructor
  Produk({
    this.id,
    this.imagePath,
    required this.codeProduk,
    required this.barcode,
    required this.nama,
    required this.kategori,
    required this.merek,
    required this.tglExpired, // Ubah dari DateTime ke String
    required this.satuanBeli,
    required this.satuanJual,
    required this.isi,
    required this.hargaBeli,
    required this.hargaJual,
    this.minStok,
    this.stok,
    this.sendNotification,
  });

  // Konversi dari map (Database ke Produk)
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String?,
      codeProduk: map['codeProduk'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      merek: map['merek'] as String? ?? '',
      tglExpired:
          map['tglExpired'] as String? ?? '', // Ubah dari DateTime ke String
      satuanBeli: map['satuanBeli'] as String?,
      satuanJual: map['satuanJual'] as String?,
      isi: map['isi'] as int?,
      hargaBeli: (map['hargaBeli'] as num?)?.toDouble() ?? 0.0,
      hargaJual: (map['hargaJual'] as num?)?.toDouble() ?? 0.0,
      minStok: map['minStok'] as int?,
      stok: map['stok'] as int?,
      sendNotification: map['sendNotification'] == 1,
    );
  }

  // Konversi ke map (Produk ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'codeProduk': codeProduk,
      'barcode': barcode,
      'nama': nama,
      'kategori': kategori,
      'merek': merek,
      'tglExpired': tglExpired, // Ubah dari DateTime ke String
      'satuanBeli': satuanBeli,
      'satuanJual': satuanJual,
      'isi': isi,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
      'minStok': minStok,
      'stok': stok,
      'sendNotification': sendNotification == true ? 1 : 0,
    };
  }

  // Save list of Produk to a file
  static Future<void> saveToFile(
      List<Produk> produkList, String filePath) async {
    final file = File(filePath);
    final jsonList = produkList.map((produk) => produk.toMap()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Load list of Produk from a file
  static Future<List<Produk>> loadFromFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Produk.fromMap(json)).toList();
  }
}

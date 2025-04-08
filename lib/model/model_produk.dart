import 'dart:convert';
import 'dart:io';

// Model untuk data produk
class Produk {
  final int? id;
  final String? imagePath;
  String nama;
  String kategori;
  String merek;
  double hargaJual;
  double hargaModal;
  String kode;
  String tglExpired;
  bool isFavorite;
  int? stok;
  int? minStok;
  String? satuan;
  bool? sendNotification;

  // Constructor
  Produk({
    this.id,
    this.imagePath,
    required this.nama,
    required this.kategori,
    required this.merek,
    required this.hargaJual,
    required this.hargaModal,
    required this.kode,
    required this.tglExpired,
    this.isFavorite = false,
    this.stok,
    this.minStok,
    this.satuan,
    this.sendNotification, // Added field to constructor
  });

  // Konversi dari map (Database ke Produk)
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String?,
      nama: map['nama'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      merek: map['merek'] as String? ?? '',
      hargaJual: (map['hargaJual'] as num?)?.toDouble() ?? 0.0,
      hargaModal: (map['hargaModal'] as num?)?.toDouble() ?? 0.0,
      kode: map['kode'] as String? ?? '',
      tglExpired: map['tglExpired'] as String? ?? '',
      isFavorite: map['isFavorite'] == 1, // 1 untuk true, 0 untuk false
      stok: map['stok'] as int?,
      minStok: map['minStok'] as int?,
      satuan: map['satuan'] as String?,
      sendNotification: map['sendNotification'] == 1, // Added field to fromMap
    );
  }

  // Konversi ke map (Produk ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'nama': nama,
      'kategori': kategori,
      'merek': merek,
      'hargaJual': hargaJual,
      'hargaModal': hargaModal,
      'kode': kode,
      'tglExpired': tglExpired,
      'isFavorite': isFavorite ? 1 : 0,
      'stok': stok,
      'minStok': minStok,
      'satuan': satuan,
      'sendNotification':
          sendNotification == true ? 1 : 0, // Added field to toMap
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

class Product {
  final int? id;
  final String? imagePath;
  String nama;
  String kategori;
  String merek;
  double hargaJual;
  double hargaModal;
  String kode;
  String tanggalKadaluwarsa;
  bool isFavorite;

  Product({
    this.id,
    this.imagePath,
    required this.nama,
    required this.kategori,
    required this.merek,
    required this.hargaJual,
    required this.hargaModal,
    required this.kode,
    required this.tanggalKadaluwarsa,
    this.isFavorite = false,
  });

  // Konversi dari map (Database ke Product)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String?,
      nama: map['nama'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      merek: map['merek'] as String? ?? '',
      hargaJual: (map['hargaJual'] as num?)?.toDouble() ?? 0.0,
      hargaModal: (map['hargaModal'] as num?)?.toDouble() ?? 0.0,
      kode: map['kode'] as String? ?? '',
      tanggalKadaluwarsa: map['tanggalKadaluwarsa'] as String? ?? '',
      isFavorite: map['isFavorite'] == 1, // 1 untuk true, 0 untuk false
    );
  }

  // Konversi ke map (Product ke Database)
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
      'tanggalKadaluwarsa': tanggalKadaluwarsa,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}

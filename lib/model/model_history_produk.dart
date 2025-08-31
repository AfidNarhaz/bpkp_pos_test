class HistoryProduk {
  final int? id;
  final String aksi;
  final String namaProduk;
  final String user;
  final String role; // Tambahkan ini
  final DateTime waktu;
  final String? detail;

  HistoryProduk({
    this.id,
    required this.aksi,
    required this.namaProduk,
    required this.user,
    required this.role, // Tambahkan ini
    required this.waktu,
    this.detail,
  });

  factory HistoryProduk.fromMap(Map<String, dynamic> map) {
    return HistoryProduk(
      id: map['id'],
      aksi: map['aksi'],
      namaProduk: map['namaProduk'],
      user: map['user'],
      role: map['role'], // Tambahkan ini
      waktu: DateTime.parse(map['waktu']),
      detail: map['detail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aksi': aksi,
      'namaProduk': namaProduk,
      'user': user,
      'role': role, // Tambahkan ini
      'waktu': waktu.toIso8601String(),
      'detail': detail,
    };
  }
}

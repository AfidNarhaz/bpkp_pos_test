class Pegawai {
  final String nama;
  final String nik;
  final String alamat;
  final DateTime tanggalLahir;
  final String fotoPath;

  Pegawai({
    required this.nama,
    required this.nik,
    required this.alamat,
    required this.tanggalLahir,
    required this.fotoPath,
  });

  // Factory constructor untuk membangun objek dari Map
  factory Pegawai.fromMap(Map<String, dynamic> map) {
    return Pegawai(
      nama: map['nama'],
      nik: map['nik'],
      alamat: map['alamat'],
      tanggalLahir: DateTime.parse(map['tanggalLahir']),
      fotoPath: map['fotoPath'],
    );
  }

  // Metode untuk mengonversi objek Pegawai menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'nik': nik,
      'alamat': alamat,
      'tanggalLahir':
          tanggalLahir.toIso8601String(), // Mengonversi DateTime ke String
      'fotoPath': fotoPath,
    };
  }
}

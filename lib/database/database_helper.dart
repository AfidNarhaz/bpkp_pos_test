import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Nama database
  static const String _dbName = 'produk.db';
  static const int _dbVersion = 1;

  // Nama tabel
  static const String tableProducts = 'products';
  static const String tablePegawai = 'pegawai';
  static const String tableKategori = 'kategori';
  static const String tableMerek = 'merek';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _dbName);
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      throw Exception("Error opening database: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProducts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        merek TEXT NOT NULL,
        hargaJual REAL NOT NULL,
        hargaModal REAL NOT NULL,
        kode TEXT NOT NULL,
        tanggalKadaluwarsa TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePegawai(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        nik TEXT,
        alamat TEXT,
        tanggalLahir TEXT,
        fotoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableKategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMerek(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  // Ambil semua produk
  Future<List<Product>> getProducts({int limit = 50, int offset = 0}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableProducts,
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // Masukkan produk baru
  Future<int> insertProduct(Product product) async {
    try {
      final db = await database;
      return await db.insert(tableProducts, product.toMap());
    } catch (e) {
      throw Exception("Error inserting product: $e");
    }
  }

  // Update produk
  Future<int> updateProduct(Product product) async {
    try {
      final db = await database;
      return await db.update(
        tableProducts,
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception("Error updating product: $e");
    }
  }

  // Hapus produk
  Future<int> deleteProduct(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableProducts,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }

  // Fungsi kategori
  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final db = await database;
      return await db.query(tableKategori);
    } catch (e) {
      throw Exception("Error fetching kategori: $e");
    }
  }

  Future<int> insertKategori(String namaKategori) async {
    try {
      final db = await database;
      return await db.insert(
        tableKategori,
        {'name': namaKategori},
      );
    } catch (e) {
      throw Exception("Error inserting kategori: $e");
    }
  }

  Future<int> updateKategori(int id, String name) async {
    try {
      final db = await database;
      return await db.update(
        tableKategori,
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error updating kategori: $e");
    }
  }

  Future<int> deleteKategori(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableKategori,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting kategori: $e");
    }
  }

  // Fungsi untuk mengambil semua merek dari database
  Future<List<Map<String, dynamic>>> getMerek() async {
    try {
      final db = await database;
      return await db.query(tableMerek);
    } catch (e) {
      throw Exception("Error fetching merek: $e");
    }
  }

  // Fungsi untuk menambahkan merek baru
  Future<int> insertMerek(String namaMerek) async {
    try {
      final db = await database;
      return await db.insert(tableMerek, {'name': namaMerek});
    } catch (e) {
      throw Exception("Error inserting merek: $e");
    }
  }

  // Fungsi untuk mengedit merek
  Future<int> updateMerek(int id, String name) async {
    try {
      final db = await database;
      return await db.update(
        tableMerek,
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error updating merek: $e");
    }
  }

  // Fungsi untuk menghapus merek
  Future<int> deleteMerek(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableMerek,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting merek: $e");
    }
  }

  // Fungsi pegawai
  Future<List<Pegawai>> getAllPegawai() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(tablePegawai);

    return maps.map((map) => Pegawai.fromMap(map)).toList();
  }

  Future<void> insertPegawai(Pegawai pegawai) async {
    final db = await database;
    await db.insert(
      tablePegawai,
      pegawai.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> closeDatabase() async {
    _database?.close();
  }
}

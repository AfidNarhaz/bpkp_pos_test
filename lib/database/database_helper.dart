import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'produk.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: (db, oldVersion, newVersion) {
          // Logic untuk migrasi database jika diperlukan
        },
      );
    } catch (e) {
      throw Exception("Error opening database: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE kategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE merek(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  // Ambil semua produk
  Future<List<Product>> getProducts({int limit = 50, int offset = 0}) async {
    try {
      Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        limit: limit,
        offset: offset,
      );
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  // Masukkan produk baru
  Future<int> insertProduct(Product product) async {
    try {
      Database db = await database;
      return await db.insert('products', product.toMap());
    } catch (e) {
      throw Exception("Error inserting product: $e");
    }
  }

  // Update produk
  Future<int> updateProduct(Product product) async {
    try {
      Database db = await database;
      return await db.update(
        'products',
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
      Database db = await database;
      return await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }

  // Fungsi untuk mengambil kategori dari database
  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      Database db = await database;
      return await db.query('kategori');
    } catch (e) {
      throw Exception("Error fetching kategori: $e");
    }
  }

  // Fungsi untuk menambahkan kategori baru
  Future<int> insertKategori(String namaKategori) async {
    try {
      Database db = await database;
      return await db.insert(
        'kategori',
        {'name': namaKategori},
      );
    } catch (e) {
      throw Exception("Error inserting kategori: $e");
    }
  }

  // Update kategori yang sudah ada
  Future<int> updateKategori(int id, String name) async {
    try {
      Database db = await database;
      return await db.update(
        'kategori',
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error updating kategori: $e");
    }
  }

  // Hapus kategori dari database
  Future<int> deleteKategori(int id) async {
    try {
      Database db = await database;
      return await db.delete(
        'kategori',
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
      Database db = await database;
      return await db.query('merek');
    } catch (e) {
      throw Exception("Error fetching merek: $e");
    }
  }

// Fungsi untuk menambahkan merek baru
  Future<int> insertMerek(String namaMerek) async {
    try {
      Database db = await database;
      return await db.insert('merek', {'name': namaMerek});
    } catch (e) {
      throw Exception("Error inserting merek: $e");
    }
  }

// Fungsi untuk mengedit merek
  Future<int> updateMerek(int id, String name) async {
    try {
      Database db = await database;
      return await db.update(
        'merek',
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
      Database db = await database;
      return await db.delete(
        'merek',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting merek: $e");
    }
  }

  Future<void> closeDatabase() async {
    _database?.close();
  }
}

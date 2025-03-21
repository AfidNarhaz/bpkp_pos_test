import 'package:flutter/material.dart';
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
  static const int _dbVersion = 2; // Incremented version

  // Nama tabel
  static const String tableProduks = 'produks';
  static const String tablePegawai = 'pegawai';
  static const String tableKategori = 'kategori';
  static const String tableMerek = 'merek';
  static const String tableSatuan = 'satuan';

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
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception("Error opening database: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProduks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        merek TEXT NOT NULL,
        hargaJual REAL NOT NULL,
        hargaModal REAL NOT NULL,
        kode TEXT NOT NULL,
        tanggalKadaluwarsa TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        stok INTEGER,
        minStok INTEGER,
        satuan TEXT,
        sendNotification INTEGER NOT NULL DEFAULT 0
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

    await db.execute('''
      CREATE TABLE $tableSatuan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stok(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        jumlah INTEGER NOT NULL DEFAULT 0,
        minStok INTEGER NOT NULL DEFAULT 0,
        satuan TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES produk(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableProduks ADD COLUMN stok INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduks ADD COLUMN minStok INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduks ADD COLUMN satuan TEXT;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduks ADD COLUMN sendNotification INTEGER NOT NULL DEFAULT 0;
      ''');
    }
  }

  // Ambil semua produk
  Future<List<Produk>> getProduks({int limit = 50, int offset = 0}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableProduks,
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => Produk.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Error fetching produks: $e");
    }
  }

  Future<List<Produk>> getProduk() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produks');

    return List.generate(maps.length, (i) {
      return Produk(
        id: maps[i]['id'],
        nama: maps[i]['nama'],
        merek: maps[i]['merek'],
        kategori: maps[i]['kategori'],
        hargaJual: maps[i]['hargaJual'] is int
            ? maps[i]['hargaJual'].toDouble()
            : maps[i]['hargaJual'],
        hargaModal: maps[i]['hargaModal'] is int
            ? maps[i]['hargaModal'].toDouble()
            : maps[i]['hargaModal'],
        kode: maps[i]['kode'],
        tanggalKadaluwarsa: maps[i]['tanggalKadaluwarsa'],
        isFavorite: maps[i]['isFavorite'] == 1,
        imagePath: maps[i]['imagePath'],
        stok: maps[i]['stok'],
        minStok: maps[i]['minStok'],
        satuan: maps[i]['satuan'],
        sendNotification:
            maps[i]['sendNotification'] == 1, // Handle sendNotification
      );
    });
  }

  // Masukkan produk baru
  Future<int> insertProduk(Produk produk) async {
    try {
      final db = await database;
      return await db.insert(tableProduks, produk.toMap());
    } catch (e) {
      throw Exception("Error inserting produk: $e");
    }
  }

  // Update produk
  Future<int> updateProduk(Produk produk) async {
    try {
      final db = await database;
      return await db.update(
        tableProduks,
        produk.toMap(),
        where: 'id = ?',
        whereArgs: [produk.id],
      );
    } catch (e) {
      throw Exception("Error updating produk: $e");
    }
  }

  // Hapus produk
  Future<int> deleteProduk(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableProduks,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting produk: $e");
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

  // Fungsi untuk mengambil semua satuan dari database
  Future<List<Map<String, dynamic>>> getSatuan() async {
    try {
      final db = await database;
      return await db.query(tableSatuan);
    } catch (e) {
      throw Exception("Error fetching satuan: $e");
    }
  }

  // Fungsi untuk menambahkan satuan baru
  Future<int> insertSatuan(String namaSatuan) async {
    try {
      final db = await database;
      return await db.insert(tableSatuan, {'name': namaSatuan});
    } catch (e) {
      throw Exception("Error inserting satuan: $e");
    }
  }

  // Fungsi untuk mengedit satuan
  Future<int> updateSatuan(int id, String name) async {
    try {
      final db = await database;
      return await db.update(
        tableSatuan,
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error updating satuan: $e");
    }
  }

  // Fungsi untuk menghapus satuan
  Future<int> deleteSatuan(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableSatuan,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting satuan: $e");
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

  Future<void> updateProductData(
      int productId, String stok, String minStok, String satuan) async {
    final db = await database;
    await db.update(
      'stok',
      {'jumlah': stok, 'minStok': minStok, 'satuan': satuan},
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    debugPrint(
        "Data stok diperbarui di database: Product ID: $productId, Stok: $stok, Minimum Stok: $minStok, Satuan: $satuan");
  }

  Future<int> insertStockData(
      int productId, String stok, String minStok, String satuan) async {
    final db = await database;
    return await db.insert('stok', {
      'product_id': productId,
      'jumlah': stok,
      'minStok': minStok,
      'satuan': satuan,
    });
  }

  Future<void> updateProdukKategori(String oldName, String newName) async {
    try {
      final db = await database;
      await db.update(
        tableProduks,
        {'kategori': newName},
        where: 'kategori = ?',
        whereArgs: [oldName],
      );
      debugPrint("Kategori produk diperbarui dari $oldName ke $newName");
    } catch (e) {
      throw Exception("Error updating produk kategori: $e");
    }
  }

  Future<void> closeDatabase() async {
    _database?.close();
  }
}

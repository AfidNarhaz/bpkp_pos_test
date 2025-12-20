import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bpkp_pos_test/model/model_produk.dart';
import 'package:bpkp_pos_test/model/model_pegawai.dart';
import 'package:bpkp_pos_test/model/user.dart';
import 'package:bpkp_pos_test/model/model_history_produk.dart';
import 'package:logger/logger.dart';

// Inisialisasi logger
final logger = Logger();

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Singleton
  factory DatabaseHelper() {
    // Jika instance sudah ada, kembalikan instance yang sudah ada
    return _instance;
  }

  // Constructor
  DatabaseHelper._internal();

  // Nama database
  static const String _dbName = 'POS.db';

  // Versi database
  static const int _dbVersion = 1;

  // Nama tabel
  static const String tableProduk = 'produk';
  static const String tableKategori = 'kategori';
  static const String tableMerek = 'merek';
  static const String tableSatuan = 'satuan';
  static const String tablePegawai = 'pegawai';
  static const String tableSupplier = 'supplier';
  static const String tablePembelian = 'pembelian';
  static const String tablePenjualan = 'penjualan';

  // Getter database
  Future<Database> get database async {
    // Jika database sudah ada, kembalikan database yang sudah ada
    if (_database != null) return _database!;

    // Jika database belum ada, inisialisasi database
    _database = await _initDatabase();

    // Kembalikan database yang sudah diinisialisasi
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDatabase() async {
    // Membuat database
    try {
      // Path database
      String path = join(await getDatabasesPath(), _dbName);

      // Membuka database
      return await openDatabase(
        // Path database
        path,

        // Versi database
        version: _dbVersion,

        // Fungsi onCreate
        onCreate: _onCreate,

        // Fungsi onUpgrade
        onUpgrade: _onUpgrade,
      );

      // Handle error
    } catch (e) {
      throw Exception("Error opening database: $e");
    }
  }

  // Fungsi untuk membuat tabel
  Future<void> _onCreate(Database db, int version) async {
    // Tabel user
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Tabel produk
    await db.execute('''
      CREATE TABLE $tableProduk(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        codeProduk TEXT NOT NULL,
        barcode TEXT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        merek TEXT NOT NULL,
        tglExpired TEXT,
        satuanUnit TEXT NOT NULL,
        hargaBeli REAL NOT NULL,
        hargaJual REAL NOT NULL,
        minStok INTEGER,
        stok INTEGER,
        sendNotification INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabel kategori
    await db.execute('''
      CREATE TABLE $tableKategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Tabel merek
    await db.execute('''
      CREATE TABLE $tableMerek(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Tabel stok
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

    // Tabel satuan
    await db.execute('''
      CREATE TABLE $tableSatuan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabel pegawai
    await db.execute('''
      CREATE TABLE $tablePegawai(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        nama TEXT,
        noHp INTEGER,
        jabatan TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    // Tabel history_produk
    await db.execute('''
      CREATE TABLE history_produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        aksi TEXT,
        namaProduk TEXT,
        user TEXT,
        role TEXT,
        waktu TEXT,
        detail TEXT
      )
    ''');

    // Tabel Pembelian
    await db.execute('''
      CREATE TABLE $tablePembelian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        supplier TEXT,
        product_id INTEGER NOT NULL,
        jumlah INTEGER,
        harga_satuan REAL,
        tanggal TEXT,
        FOREIGN KEY (product_id) REFERENCES produk(id) ON DELETE CASCADE
    )
    ''');

    // Tabel Penjualan
    await db.execute('''
      CREATE TABLE $tablePenjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        noInvoice TEXT,
        produkId INTEGER,
        jumlah INTEGER,
        hargaSatuan REAL,
        totalHarga REAL,
        tanggal TEXT,
        FOREIGN KEY (produkId) REFERENCES produk(id) ON DELETE CASCADE
      )
    ''');

    // Tabel notifikasi
    await db.execute('''
      CREATE TABLE notifikasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT,
        stok INTEGER,
        tanggal TEXT
      )
    ''');
  }
  //---------------------------------------------------------------------------

  // Fungsi untuk mengupgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await db.execute('''
        ALTER TABLE $tableProduk ADD COLUMN stok INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduk ADD COLUMN minStok INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduk ADD COLUMN satuan TEXT;
      ''');
      await db.execute('''
        ALTER TABLE $tableProduk ADD COLUMN sendNotification INTEGER NOT NULL DEFAULT 0;
      ''');
    }
  }

  // Fungsi untuk mengambil semua produk
  Future<List<Produk>> getProduk() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produk');
    return List.generate(maps.length, (i) {
      return Produk(
        id: maps[i]['id'], // Handle id
        imagePath: maps[i]['imagePath'], // Handle imagePath
        codeProduk: maps[i]['codeProduk'], // Handle codeProduk
        barcode: maps[i]['barcode'], // Handle barcode
        nama: maps[i]['nama'], // Handle nama
        kategori: maps[i]['kategori'], // Handle kategori
        merek: maps[i]['merek'], // Handle merek
        tglExpired: maps[i]['tglExpired'], // Handle tanggalKadaluwarsa
        satuanUnit: maps[i]['satuanUnit'], // Handle satuan unit
        hargaBeli: maps[i]['hargaBeli'] is int
            ? maps[i]['hargaBeli'].toDouble()
            : maps[i]['hargaBeli'], // Handle hargaBeli
        hargaJual: maps[i]['hargaJual'] is int
            ? maps[i]['hargaJual'].toDouble()
            : maps[i]['hargaJual'], // Handle hargaJual
        minStok: maps[i]['minStok'], // Handle minStok
        stok: maps[i]['stok'], // Handle stok
        sendNotification:
            maps[i]['sendNotification'] == 1, // Handle sendNotification
      );
    });
  }

  // Fungsi untuk menambahkan user baru
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi untuk mendapatkan user berdasarkan username dan password
  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Fungsi untuk menambahkan user default jika tabel kosong
  Future<void> seedUsers() async {
    final db = await database;
    final existing = await db.query('users');
    if (existing.isEmpty) {
      await insertUser(
          User(username: 'Difa', password: 'Difa123', role: 'admin'));
      await insertUser(
          User(username: 'Ansel', password: 'Ansel123', role: 'kasir'));
    }
  }

  // Fungsi untuk mengambil semua produk
  Future<List<Produk>> getProduks({int limit = 50, int offset = 0}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableProduk,
        limit: limit,
        offset: offset,
      );
      return maps.map((map) => Produk.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Error fetching produk: $e");
    }
  }

  // Masukkan produk baru
  Future<int> insertProduk(Produk produk) async {
    try {
      final db = await database;
      return await db.insert(tableProduk, produk.toMap());
    } catch (e) {
      throw Exception("Error inserting produk: $e");
    }
  }

  // Update produk
  Future<int> updateProduk(Produk produk) async {
    try {
      final db = await database;
      return await db.update(
        tableProduk,
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
        tableProduk,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting produk: $e");
    }
  }

  // Fungsi untuk mengambil semua kategori dari database
  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final db = await database;
      return await db.query(tableKategori);
    } catch (e) {
      throw Exception("Error fetching kategori: $e");
    }
  }

  // Fungsi untuk menambahkan kategori baru
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

  // Fungsi untuk mengedit kategori
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

  // Fungsi untuk menghapus kategori
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
      // Urutkan A-Z (case-insensitive)
      return await db.query(tableSatuan, orderBy: 'name COLLATE NOCASE ASC');
    } catch (e) {
      throw Exception("Error fetching satuan: $e");
    }
  }

  // Fungsi untuk menambahkan satuan baru
  Future<int> insertSatuan(String namaSatuan) async {
    try {
      final db = await database;
      final sanitized = namaSatuan.trim();
      if (sanitized.isEmpty) {
        throw Exception("Nama satuan kosong");
      }
      // Cek apakah sudah ada (case-insensitive)
      final exists = await db.query(
        tableSatuan,
        where: 'LOWER(name) = ?',
        whereArgs: [sanitized.toLowerCase()],
      );
      if (exists.isNotEmpty) {
        // Kembalikan id jika sudah ada
        return exists.first['id'] as int;
      }
      // Masukkan baru
      return await db.insert(tableSatuan, {'name': sanitized});
    } catch (e) {
      throw Exception("Error inserting satuan: $e");
    }
  }

  // Fungsi untuk mengedit satuan
  Future<int> updateSatuan(int id, String name) async {
    try {
      final db = await database;
      final sanitized = name.trim();
      if (sanitized.isEmpty) {
        throw Exception("Nama satuan kosong");
      }
      // Hindari duplikat nama (case-insensitive) untuk id lain
      final dup = await db.query(
        tableSatuan,
        where: 'LOWER(name) = ? AND id != ?',
        whereArgs: [sanitized.toLowerCase(), id],
      );
      if (dup.isNotEmpty) {
        throw Exception("Nama satuan sudah ada");
      }
      return await db.update(
        tableSatuan,
        {'name': sanitized},
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

  // Fungsi untuk memperbarui kategori produk ketika kategori diubah
  Future<void> updateProdukKategori(String oldName, String newName) async {
    try {
      final db = await database;
      await db.update(
        tableProduk,
        {'kategori': newName},
        where: 'kategori = ?',
        whereArgs: [oldName],
      );
      debugPrint("Kategori produk diperbarui dari $oldName ke $newName");
    } catch (e) {
      throw Exception("Error updating produk kategori: $e");
    }
  }

  // Fungsi untuk ambil list data pembelian
  Future<List<Map<String, dynamic>>> getListPembelian({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String? start =
        startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : null;
    String? end =
        endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : null;

    String whereClause = '';
    List<String> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE tanggal >= ? AND tanggal <= ?';
      whereArgs = [start, end];
    } else if (start != null) {
      whereClause = 'WHERE tanggal >= ?';
      whereArgs = [start];
    } else if (end != null) {
      whereClause = 'WHERE tanggal <= ?';
      whereArgs = [end];
    }

    final result = await db.rawQuery('''
    SELECT code, supplier, MAX(tanggal) AS tanggal
    FROM $tablePembelian
    $whereClause
    GROUP BY code
    ORDER BY tanggal DESC
  ''', whereArgs);

    return result;
  }

  // Fungsi untuk ambil list data penjualan
  Future<List<Map<String, dynamic>>> getListPenjualan({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String? start =
        startDate != null ? DateFormat('dd-MM-yyyy').format(startDate) : null;
    String? end =
        endDate != null ? DateFormat('dd-MM-yyyy').format(endDate) : null;

    String whereClause = '';
    List<String> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE tanggal >= ? AND tanggal <= ?';
      whereArgs = [start, end];
    } else if (start != null) {
      whereClause = 'WHERE tanggal >= ?';
      whereArgs = [start];
    } else if (end != null) {
      whereClause = 'WHERE tanggal <= ?';
      whereArgs = [end];
    }

    final result = await db.rawQuery('''
    SELECT noInvoice, MAX(tanggal) AS tanggal, SUM(totalHarga) AS total_transaksi
    FROM $tablePenjualan
    $whereClause
    GROUP BY noInvoice
    ORDER BY tanggal DESC
  ''', whereArgs);

    return result;
  }

  // Fungsi untuk mengambil daftar barang di penjualan
  Future<List<Map<String, dynamic>>> getDetailBarangPenjualan(
      String noInvoice) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT p.id, p.codeProduk, p.nama, p.kategori, p.merek, 
           p.hargaJual, pp.jumlah, pp.totalHarga
    FROM $tablePenjualan pp
    JOIN $tableProduk p ON pp.produkId = p.id
    WHERE pp.noInvoice = ?
  ''', [noInvoice]);

    return result;
  }

  // Fungsi untuk mengambil daftar barang di pembelian
  Future<List<Map<String, dynamic>>> getDetailBarangPembelian(
      String code) async {
    final db = await database;

    String query = '''
    SELECT 
        p.codeProduk, 
        p.nama, 
        p.kategori, 
        p.merek, 
        p.satuanUnit,
        p.hargaBeli, 
        p.hargaJual, 
        p.minStok, 
        pb.jumlah, 
        pb.harga_satuan,
        pb.tanggal
    FROM pembelian pb
    JOIN produk p ON pb.product_id = p.id
    WHERE pb.code = ?
  ''';

    List<Map<String, dynamic>> result = await db.rawQuery(query, [code]);
    logger.i('Result : $result');

    return result;
  }

  // Fungsi untuk memasukkan pembelian baru
  Future<void> insertPembelian(List<Map<String, dynamic>> barangList,
      String supplier, String tanggalPembelian) async {
    final db = await database;

    String timestamp = DateTime.now().toString();
    String formattedDate = timestamp
        .replaceAll("-", "")
        .replaceAll(":", "")
        .replaceAll(" ", "_")
        .split(".")[0];
    String code = 'RN_$formattedDate';

    await db.transaction((txn) async {
      for (var barang in barangList) {
        await txn.insert(
          tablePembelian,
          {
            'code': code,
            'supplier': supplier,
            'product_id': barang['id_barang'],
            'tanggal': tanggalPembelian,
            'jumlah': barang['stok'],
            'harga_satuan': barang['harga_beli'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.rawUpdate('''
          UPDATE $tableProduk
          SET stok = COALESCE(stok, 0) + ?
          WHERE id = ?
        ''', [barang['stok'], barang['id_barang']]);
      }
    });
  }

  // Fungsi untuk memasukkan penjualan baru
  Future<void> insertPenjualan(List<Map<String, dynamic>> barangList) async {
    final db = await database;

    final now = DateTime.now();
    final formattedTimestamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final formattedTanggal = DateFormat('dd-MM-yyyy').format(now);

    final invoice = 'INVOICE_$formattedTimestamp';

    await db.transaction((txn) async {
      for (var barang in barangList) {
        double hargaSatuan = barang['hargaJual'];
        int jumlah = barang['qty'];
        double totalHarga = barang['total'];

        await txn.insert(
          tablePenjualan,
          {
            'noInvoice': invoice,
            'produkId': barang['id'],
            'jumlah': jumlah,
            'hargaSatuan': hargaSatuan,
            'totalHarga': totalHarga,
            'tanggal': formattedTanggal,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.rawUpdate('''
        UPDATE $tableProduk
        SET stok = COALESCE(stok, 0) - ?
        WHERE id = ?
      ''', [jumlah, barang['id']]);
      }
    });
  }

  // Fungsi untuk mengambil semua supplier dari database
  Future<List<Map<String, dynamic>>> getSupplier() async {
    try {
      final db = await database;
      return await db.query(tableSupplier);
    } catch (e) {
      throw Exception("Error fetching supplier: $e");
    }
  }

  // Fungsi untuk menambahkan supplier baru
  Future<int> insertSupplier(String namaSupplier) async {
    try {
      final db = await database;
      return await db.insert(
        tableSupplier,
        {'name': namaSupplier},
      );
    } catch (e) {
      throw Exception("Error inserting supplier: $e");
    }
  }

  // Fungsi untuk mengedit supplier
  Future<int> updateSupplier(int id, String name) async {
    try {
      final db = await database;
      return await db.update(
        tableSupplier,
        {'name': name},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error updating supplier: $e");
    }
  }

  // Fungsi untuk menghapus supplier
  Future<int> deleteSupplier(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableSupplier,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting supplier: $e");
    }
  }

  // Fungsi untuk mengambil semua pegawai
  Future<List<Pegawai>> getAllPegawai() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(tablePegawai);

    return maps.map((map) => Pegawai.fromMap(map)).toList();
  }

  // Fungsi untuk menambahkan pegawai
  Future<void> insertPegawai(Pegawai pegawai) async {
    final db = await database;
    await db.insert(
      tablePegawai,
      pegawai.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi untuk mengedit pegawai
  Future<void> updatePegawai(Pegawai pegawai) async {
    final db = await database;
    await db.update(
      tablePegawai,
      pegawai.toMap(),
      where: 'id = ?',
      whereArgs: [pegawai.id],
    );
  }

  // Fungsi untuk menghapus pegawai
  Future<int> deletePegawai(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tablePegawai,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Error deleting pegawai: $e");
    }
  }

  // Fungsi untuk menutup database
  Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        debugPrint("Database closed successfully.");
      }
    } catch (e) {
      throw Exception("Error closing database: $e");
    }
  }

  // Fungsi untuk memperbarui user
  Future<void> updateUser(String oldUsername, User updatedUser) async {
    final db = await database;
    await db.update(
      'users',
      {
        'username': updatedUser.username,
        'password': updatedUser.password,
        'role': updatedUser.role,
      },
      where: 'username = ?',
      whereArgs: [oldUsername],
    );
  }

  // Fungsi untuk mengambil semua history produk
  Future<List<HistoryProduk>> getAllHistoryProduk() async {
    final db = await database;
    final result = await db.query('history_produk', orderBy: 'waktu DESC');
    return result.map((e) => HistoryProduk.fromMap(e)).toList();
  }

  // Fungsi untuk menambahkan history produk
  Future<void> insertHistoryProduk(HistoryProduk history) async {
    final db = await database;
    await db.insert('history_produk', history.toMap());
  }

  // Fungsi untuk mengambil produk yang hampir kadaluarsa
  Future<List<Produk>> getProdukHampirExpired() async {
    final db = await database;
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final result = await db.query(
      'produk',
      where:
          'tglExpired IS NOT NULL AND tglExpired != "" AND tglExpired BETWEEN ? AND ?',
      whereArgs: [
        DateFormat('dd-MM-yyyy').format(now),
        DateFormat('dd-MM-yyyy').format(nextWeek),
      ],
    );
    return result.map((e) => Produk.fromMap(e)).toList();
  }

  // Fungsi untuk memasukkan notifikasi baru
  Future<void> insertNotifikasi(String judul, String stok) async {
    final db = await database;
    await db.insert('notifikasi', {
      'judul': judul,
      'stok': stok,
      'tanggal': DateTime.now().toIso8601String(),
    });
  }

  // Fungsi untuk mengambil semua notifikasi
  Future<List<Map<String, dynamic>>> getNotifikasi() async {
    final db = await database;
    return await db.query('notifikasi', orderBy: 'tanggal DESC');
  }
}

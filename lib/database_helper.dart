import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE products (
  id $idType,
  namaProduk $textType,
  hargaProduk $textType,
  stokProduk $textType,
  minimumStock $textType,
  isChecked $boolType
  )
''');
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final db = await instance.database;

    await db.insert('products', product);
  }
}

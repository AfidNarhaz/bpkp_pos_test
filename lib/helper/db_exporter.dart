import 'dart:io';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DbExporter {
  static const String dbName = 'POS.db';

  static Future<String?> exportDatabase() async {
    // Minta izin storage (Android < 13)
    await Permission.storage.request();

    // Lokasi database internal app
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, dbName);

    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw Exception('Database tidak ditemukan');
    }

    // Folder Download
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final exportPath = join(downloadDir.path, dbName);

    // Copy & overwrite
    await dbFile.copy(exportPath);

    return exportPath;
  }
}

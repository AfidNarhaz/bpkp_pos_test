import 'dart:io';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class DbExporter {
  static const String dbName = 'POS.db';

  static Future<String?> exportDatabase() async {
    try {
      // Request permission dengan pengecekan status
      await _requestStoragePermission();

      // Lokasi database internal app
      final dbDir = await getDatabasesPath();
      final dbPath = join(dbDir, dbName);

      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw Exception('Database tidak ditemukan di: $dbPath');
      }

      logger.i('Database ditemukan: $dbPath');

      // Dapatkan folder Download
      final downloadDir = Directory('/storage/emulated/0/Download');

      // Jika folder tidak ada, buat folder Documents sebagai alternatif
      if (!await downloadDir.exists()) {
        logger.w('Folder Download tidak ada, mencoba Documents...');
        final docsDir = Directory('/storage/emulated/0/Documents');
        if (!await docsDir.exists()) {
          await docsDir.create(recursive: true);
        }
        return await _copyDatabase(dbFile, docsDir);
      }

      // Copy ke Download folder
      return await _copyDatabase(dbFile, downloadDir);
    } catch (e) {
      logger.e('Error export database: $e');
      rethrow;
    }
  }

  /// Copy database file dengan error handling
  static Future<String?> _copyDatabase(
    File sourceFile,
    Directory targetDir,
  ) async {
    try {
      final exportPath = join(targetDir.path, dbName);

      // Hapus file lama jika ada
      final existingFile = File(exportPath);
      if (await existingFile.exists()) {
        await existingFile.delete();
        logger.i('File lama dihapus: $exportPath');
      }

      // Copy file
      await sourceFile.copy(exportPath);
      logger.i('Database berhasil diexport ke: $exportPath');

      return exportPath;
    } catch (e) {
      logger.e('Error saat copy file: $e');
      rethrow;
    }
  }

  /// Request storage permission dengan pengecekan
  static Future<void> _requestStoragePermission() async {
    try {
      // Untuk Android: request MANAGE_EXTERNAL_STORAGE
      final status = await Permission.manageExternalStorage.request();

      logger.i('Permission status: $status');

      if (status.isDenied) {
        logger.e('Permission DITOLAK pengguna');
        throw Exception('Izin akses storage ditolak');
      }

      if (status.isPermanentlyDenied) {
        logger.e('Permission PERMANENTLY DENIED - perlu buka settings');
        throw Exception(
          'Izin akses storage ditolak permanen. Silakan ubah di Settings > Aplikasi > Izin',
        );
      }

      logger.i('Permission GRANTED');
    } catch (e) {
      logger.e('Error request permission: $e');
      rethrow;
    }
  }
}

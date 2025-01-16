import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('ImageServiceLogger');

class ImageService {
  late Database _db;

  /// Inisialisasi database
  Future<void> initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'images.db');

      _db = await openDatabase(
        path,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT NOT NULL)',
          );
        },
        version: 1,
      );

      _logger.info("Database initialized at $path");
    } catch (e) {
      _logger.severe("Error initializing database: $e");
    }
  }

  /// Ambil gambar dari kamera dan simpan ke storage lokal
  Future<File?> pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        // Validasi direktori penyimpanan
        final directory = await getApplicationDocumentsDirectory();
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Simpan gambar
        final imagePath = join(
          directory.path,
          'image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        final savedImage = await File(pickedFile.path).copy(imagePath);

        // Simpan path gambar ke database
        await _db.insert(
          'images',
          {'path': savedImage.path},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        _logger.info("Image saved at: ${savedImage.path}");
        return savedImage;
      } else {
        _logger.warning("No image was picked.");
      }
    } on PlatformException catch (e) {
      _logger.severe("PlatformException while picking an image: ${e.message}");
    } on FileSystemException catch (e) {
      _logger
          .severe("FileSystemException while picking an image: ${e.message}");
    } catch (e) {
      _logger.severe("Unexpected error while picking or saving image: $e");
    }
    return null;
  }

  /// Ambil path gambar berdasarkan ID
  Future<String?> getImagePath(int id) async {
    try {
      final result = await _db.query(
        'images',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final path = result.first['path'] as String;
        _logger.info("Image path retrieved for ID $id: $path");
        return path;
      } else {
        _logger.warning("No image found for ID $id.");
      }
    } catch (e) {
      _logger.severe("Error retrieving image path for ID $id: $e");
    }
    return null;
  }

  /// Ambil semua gambar yang tersimpan di database
  Future<List<Map<String, dynamic>>> getAllImages() async {
    try {
      final result = await _db.query('images');
      _logger.info("Retrieved ${result.length} images from the database.");
      return result;
    } catch (e) {
      _logger.severe("Error retrieving all images: $e");
      return [];
    }
  }

  /// Hapus gambar berdasarkan ID
  Future<void> deleteImage(int id) async {
    try {
      // Ambil path gambar sebelum menghapus
      final path = await getImagePath(id);

      if (path != null) {
        // Hapus file fisik jika ada
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          _logger.info("Deleted image file at: $path");
        }

        // Hapus entri database
        await _db.delete(
          'images',
          where: 'id = ?',
          whereArgs: [id],
        );
        _logger.info("Deleted image record with ID $id from database.");
      }
    } catch (e) {
      _logger.severe("Error deleting image with ID $id: $e");
    }
  }

  /// Tutup database
  Future<void> closeDb() async {
    try {
      await _db.close();
      _logger.info("Database closed.");
    } catch (e) {
      _logger.severe("Error closing database: $e");
    }
  }
}

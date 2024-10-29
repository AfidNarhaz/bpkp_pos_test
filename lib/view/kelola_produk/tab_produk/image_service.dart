import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('KelolaProdukLogger');

class ImageService {
  late Database _db;

  Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'images.db');

    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db
            .execute('CREATE TABLE images(id INTEGER PRIMARY KEY, path TEXT)');
      },
      version: 1,
    );
  }

  Future<File?> pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = join(directory.path, 'image_${DateTime.now()}.png');
        final savedImage = await File(pickedFile.path).copy(imagePath);

        // Simpan path gambar ke database
        await _db.insert('images', {'path': savedImage.path});

        return savedImage;
      }
    } catch (e) {
      _logger.severe("Error while picking image: $e");
    }
    return null;
  }

  Future<String?> getImagePath(int id) async {
    final result =
        await _db.query('images', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isNotEmpty) {
      return result.first['path'] as String?;
    }
    return null;
  }
}

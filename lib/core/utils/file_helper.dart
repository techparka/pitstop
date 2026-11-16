import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static const invoiceImageExtensions = ['jpg', 'jpeg', 'png'];

  static bool isInvoiceImagePath(String path) {
    final extension = p.extension(path).toLowerCase();
    return invoiceImageExtensions.any((format) => extension == '.$format');
  }

  static Future<Directory> _baseDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'car_service'));
  }

  static Future<String> copyVehiclePhoto(
      String sourcePath, int vehicleId) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'vehicles', '$vehicleId'));
    await dir.create(recursive: true);
    final ext = p.extension(sourcePath);
    final dest = p.join(dir.path, 'photo$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  static Future<String> copyServiceAttachment(
      String sourcePath, int serviceId, String fileName) async {
    final base = await _baseDir();
    final dir =
        Directory(p.join(base.path, 'services', '$serviceId', 'attachments'));
    await dir.create(recursive: true);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(sourcePath);
    final dest = p.join(dir.path, '${ts}_$fileName$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  static Future<String> prepareAttachment(String source) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'files'));
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '${const Uuid().v4()}${p.extension(source)}');
    await File(source).copy(dest);
    return dest;
  }

  static Future<void> deleteFile(String filePath) async {
    final f = File(filePath);
    if (await f.exists()) await f.delete();
  }

  static Future<void> deleteVehicleDir(int vehicleId) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'vehicles', '$vehicleId'));
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  static Future<void> deleteServiceDir(int serviceId) async {
    final base = await _baseDir();
    final dir = Directory(p.join(base.path, 'services', '$serviceId'));
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}

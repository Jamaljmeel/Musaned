import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Upload a file and return the download URL
  Future<String> uploadFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    final name = fileName ?? '${_uuid.v4()}.${file.path.split('.').last}';
    final ref = _storage.ref().child('$path/$name');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Upload multiple files
  Future<List<String>> uploadFiles({
    required List<File> files,
    required String path,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadFile(file: file, path: path);
      urls.add(url);
    }
    return urls;
  }

  /// Delete a file by URL
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // File may not exist
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles(List<String> urls) async {
    for (final url in urls) {
      await deleteFile(url);
    }
  }
}

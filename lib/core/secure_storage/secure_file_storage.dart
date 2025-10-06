import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' show AES, Encrypter, IV, Key, AESMode, Encrypted;
import 'package:path_provider/path_provider.dart';

class SecureFileStorage {
  final Key key;

  SecureFileStorage(List<int> keyBytes)
      : key = Key(Uint8List.fromList(keyBytes));

  Future<String> saveEncryptedFile(String fileName, Uint8List data) async {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encryptBytes(data, iv: iv);

    final fileData = iv.bytes + encrypted.bytes;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.enc');
    await file.writeAsBytes(fileData, flush: true);

    return file.path;
  }

  Future<Uint8List> readEncryptedFile(String path) async {
    try {
      final fileData = await File(path).readAsBytes();
      final iv = IV(fileData.sublist(0, 16));
      final ciphertext = fileData.sublist(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e, st) {
      rethrow;
    }
  }

  String getMimeTypeFromBytes(Uint8List bytes) {
    try {
      if (bytes.length >= 3) {
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
          return 'image/jpeg';
        }
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
          return 'image/png';
        }
        if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
          return 'application/pdf';
        }
      }

      return 'application/octet-stream';
    } catch (e) {
      return 'application/octet-stream';
    }
  }

  String? getFileExtension(Uint8List bytes) {
    String? mimeType = getMimeTypeFromBytes(bytes);

    /**
     * i could remove pdf and bin case but in order to extend
     */
    switch (mimeType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'application/pdf':
        return '.pdf';
      default:
        return '.bin';
    }
  }

  Future<File> createTempFileFromBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final tempFile = File('${tempDir.path}/$fileName.');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }





}

import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' show AES, Encrypter, IV, Key, AESMode, Encrypted;
import 'package:path_provider/path_provider.dart';

class SecureFileStorage {
  final Key key;

  SecureFileStorage(List<int> keyBytes)
      : key = Key(Uint8List.fromList(keyBytes));

  /// Enregistre un fichier chiffré : [IV + ciphertext]
  Future<String> saveEncryptedFile(String fileName, Uint8List data) async {
    final iv = IV.fromSecureRandom(16); // IV unique par fichier
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encryptBytes(data, iv: iv);

    // On concatène IV + ciphertext
    final fileData = iv.bytes + encrypted.bytes;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.enc');
    await file.writeAsBytes(fileData, flush: true);

    return file.path;
  }

  /// Relit un fichier chiffré et le déchiffre
  Future<Uint8List> readEncryptedFile(String path) async {
    final fileData = await File(path).readAsBytes();

    // Séparer IV et ciphertext
    final iv = IV(fileData.sublist(0, 16));
    final ciphertext = fileData.sublist(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decryptBytes(Encrypted(ciphertext), iv: iv);

    return Uint8List.fromList(decrypted);
  }
}

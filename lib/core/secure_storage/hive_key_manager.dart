import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiveKeyManager {
  static const _keyName = 'enc_key_hive';
  final FlutterSecureStorage storage;

  const HiveKeyManager(this.storage);

  Future<List<int>> getOrCreateKey() async {
    final base64Key = await storage.read(key: _keyName);
    if (base64Key != null) return base64Decode(base64Key);
    List<int> key;
    try {
      key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    } catch (e) {
      key = List<int>.generate(32, (_) => Random().nextInt(256));
    }
    await storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }

  Future<void> deleteKey() => storage.delete(key: _keyName);
}
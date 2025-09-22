import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:kyc/data/models/hive/kyc_local_model.dart';

import '../../../core/secure_storage/hive_key_manager.dart';
import '../../../core/secure_storage/secure_file_storage.dart';
import '../../../domain/entities/kyc.dart';

class KycLocalDataSource {
  static const _boxName = 'pending_kyc_box';

  final SecureFileStorage _fileStorage;
  final List<int> encryptionKey;

  const KycLocalDataSource({required this.encryptionKey, required SecureFileStorage fileStorage}) : _fileStorage = fileStorage;

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<void> savePending(KycLocalModel item) async {
    final box = Hive.box(_boxName);
    await box.put(item.id, item.toJson());
  }

  List<Kyc> getAllPending() {
    final box = Hive.box(_boxName);
    return box.keys.map((k) {
      final raw = Map<String, dynamic>.from(box.get(k));
      return Kyc.fromJson(raw);
    }).toList();
  }

  Future<void> deletePending(String id) async {
    final box = Hive.box(_boxName);
    await box.delete(id);
  }
}
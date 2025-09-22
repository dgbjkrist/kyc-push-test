import 'dart:convert';
import 'dart:io';

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

  Future<void> savePending(Kyc kyc) async {
    final [faceImage, rectoImage, versoImage] = await Future.wait([
      File(kyc.faceImagePath).readAsBytes(),
      File(kyc.cardRectoPath).readAsBytes(),
      if (kyc.cardVersoPath != null) File(kyc.cardVersoPath!).readAsBytes(),
    ]);

    final [facePath, rectoPath, versoPath] = await Future.wait([
      _fileStorage.saveEncryptedFile('${kyc.id}_face', faceImage),
      _fileStorage.saveEncryptedFile('${kyc.id}_recto', rectoImage),
      if (kyc.cardVersoPath != null) _fileStorage.saveEncryptedFile('${kyc.id}_verso', versoImage),
    ]);

    final box = Hive.box(_boxName);
    await box.put(kyc.id, {
      'id': kyc.id,
      'fullName': kyc.fullName,
      'dateOfBirth': kyc.dateOfBirth,
      'nationality': kyc.nationality,
      'faceImagePath': facePath,
      'cardRectoPath': rectoPath,
      'cardVersoPath': versoPath,
      'synced': kyc.synced,
      'createdAt': kyc.createdAt,
    });
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
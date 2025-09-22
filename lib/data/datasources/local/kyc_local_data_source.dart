import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
    print("Saving pending kyc: ${kyc.faceImagePath} ${kyc.cardRectoPath} ${kyc.cardVersoPath}");
    List<Future<Uint8List>> uint8ListFutures = [
      File(kyc.faceImagePath).readAsBytes(),
      File(kyc.cardRectoPath).readAsBytes(),
      ];

      if (kyc.cardVersoPath != null && kyc.cardVersoPath!.isNotEmpty) uint8ListFutures.add(File(kyc.cardVersoPath!).readAsBytes());

    final results = await Future.wait(uint8ListFutures);

    Uint8List faceImage = results[0];
    Uint8List rectoImage = results[1];
    Uint8List? versoImage = results.length > 2 ? results[2] : null;

      List<Future<String?>> encryptedFileFutures = [
        _fileStorage.saveEncryptedFile('${kyc.id}_face', faceImage),
        _fileStorage.saveEncryptedFile('${kyc.id}_recto', rectoImage),
        ];

      if (versoImage != null) encryptedFileFutures.add(_fileStorage.saveEncryptedFile('${kyc.id}_verso', versoImage));

    final paths = await Future.wait(encryptedFileFutures);
    String facePath = paths[0]!;
    String rectoPath = paths[1]!;
    String? versoPath = paths.length > 2 ? paths[2] : null;

    final box = Hive.box(_boxName);
    await box.put(kyc.id, {
      'id': kyc.id,
      'id_type': kyc.idType,
      'full_name': kyc.fullName.value,
      'date_of_birth': kyc.dateOfBirth.value,
      'nationality': kyc.nationality.value,
      'face_path': facePath,
      'recto_path': rectoPath,
      'verso_path': versoPath,
      'synced': kyc.synced,
      'created_at': kyc.createdAt,
    });
  }

  Future<List<Kyc>> getAllPending() async {
    final box = Hive.box(_boxName);
    final keys = box.keys.toList();

    final futures = keys.map((key) async {
      final raw = Map<String, dynamic>.from(box.get(key));
      return Kyc.fromJson(raw);
    }).toList();
    return await Future.wait(futures);
  }

  Future<void> deletePending(String id) async {
    final box = Hive.box(_boxName);
    await box.delete(id);
  }
}
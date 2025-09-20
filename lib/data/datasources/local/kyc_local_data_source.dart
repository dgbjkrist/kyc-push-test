import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/kyc.dart';

class KycLocalDataSource {
  static const _boxName = 'pending_kyc_box';

  Future<void> init(List<int> encryptionKey) async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName, encryptionCipher: HiveAesCipher(encryptionKey));
  }

  Future<void> savePending(Kyc item) async {
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
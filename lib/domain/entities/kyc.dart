import '../value_objects/date_of_birth.dart';
import '../value_objects/full_name.dart';
import '../value_objects/nationality.dart';

class Kyc {
  final String id;
  final String idType;
  final FullName fullName;
  final DateOfBirth dateOfBirth;
  final Nationality nationality;
  final String faceImagePath;
  final String cardRectoPath;
  final String? cardVersoPath;
  final bool synced;
  final DateTime? createdAt;

  Kyc({
    required this.id,
    required this.idType,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.faceImagePath,
    required this.cardRectoPath,
    this.cardVersoPath,
    this.synced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'idType': idType,
    'full_name': fullName.value,
    'date_of_birth': dateOfBirth.value,
    'nationality': nationality.value,
    'face_path': faceImagePath,
    'recto_path': cardRectoPath,
    'verso_path': cardVersoPath,
    'synced': synced,
    'created_at': createdAt?.toIso8601String(),
  };

  factory Kyc.fromJson(Map<String, dynamic> j) => Kyc(
    id: j['id'] as String,
    idType: j['idType'] as String,
    fullName: FullName(j['full_name'] as String),
    dateOfBirth: DateOfBirth(j['date_of_birth'] as String),
    nationality: Nationality(j['nationality'] as String),
    faceImagePath: j['face_path'] as String,
    cardRectoPath: j['recto_path'] as String,
    cardVersoPath: j['verso_path'] as String?,
    synced: j['synced'] as bool? ?? false,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}
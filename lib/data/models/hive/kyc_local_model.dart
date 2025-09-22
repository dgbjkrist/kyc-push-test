class KycLocalModel {
  final String id;
  final String fullName;
  final String dateOfBirth;
  final String nationality;
  final String? faceImagePath;
  final String? cardRectoPath;
  final String? cardVersoPath;
  final bool synced;
  final String createdAt;

  KycLocalModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    this.faceImagePath,
    this.cardRectoPath,
    this.cardVersoPath,
    this.synced = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'dateOfBirth': dateOfBirth,
    'nationality': nationality,
    'faceImagePath': faceImagePath,
    'cardRectoPath': cardRectoPath,
    'cardVersoPath': cardVersoPath,
    'synced': synced,
    'createdAt': createdAt,
  };

  factory KycLocalModel.fromJson(Map<String, dynamic> j) => KycLocalModel(
    id: j['id'] as String,
    fullName: j['fullName'] as String,
    dateOfBirth: j['dateOfBirth'] as String,
    nationality: j['nationality'] as String,
    faceImagePath: j['faceImagePath'] as String,
    cardRectoPath: j['cardRectoPath'] as String,
    cardVersoPath: j['cardVersoPath'] as String?,
    synced: j['synced'] as bool? ?? false,
    createdAt: j['createdAt'] as String,
  );
}

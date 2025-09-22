import 'dart:typed_data';

enum DocumentType {
  identityCard,
  passport,
  driverLicense,
  utilityBill,
  bankStatement,
  other
}

extension DocumentTypeExtension on String {
  DocumentType toDocumentType() {
    switch (this) {
      case 'cni':
        return DocumentType.identityCard;
      case 'passport':
        return DocumentType.passport;
      case 'driver_license':
        return DocumentType.driverLicense;
      default:
        return DocumentType.other;
    }
  }
}

sealed class DocumentContent {}

class DocumentPath extends DocumentContent {
  final String path;
  DocumentPath(this.path);
}

class DocumentBytes extends DocumentContent {
  final Uint8List data;
  DocumentBytes(this.data);
}

class KycDocument {
  final DocumentType type;
  final DocumentContent content;
  final String? documentType; // Pour l'API (ex: "identity_card")

  KycDocument({
    required this.type,
    required this.content,
    this.documentType,
  });

  // Pour les documents provenant de l'API (avec chemin distant)
  factory KycDocument.fromRemoteJson(Map<String, dynamic> json) {
    return KycDocument(
      type: (json['document_type'] as String).toDocumentType(),
      content: DocumentPath(json['file_path']), // ← Chemin du serveur
      documentType: json['document_type'],
    );
  }

  // Pour les documents locaux (avec bytes)
  factory KycDocument.fromLocalJson(Map<String, dynamic> json) {
    return KycDocument(
      type: (json['type'] as String).toDocumentType(),
      content: DocumentBytes(json['bytes']), // ← Bytes décryptés
      documentType: json['type'],
    );
  }

  // Factory pour créer un document local avec bytes
  factory KycDocument.fromBytes({
    required DocumentType type,
    required Uint8List bytes,
  }) {
    final documentType = _documentTypeToString(type);
    return KycDocument(
      type: type,
      content: DocumentBytes(bytes),
      documentType: documentType,
    );
  }

  // Factory pour créer un document local avec type string
  factory KycDocument.fromBytesWithStringType({
    required String type,
    required Uint8List bytes,
  }) {
    return KycDocument(
      type: type.toDocumentType(),
      content: DocumentBytes(bytes),
      documentType: type,
    );
  }

  // Convertir le type en string pour l'API
  static String _documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.identityCard:
        return 'cni';
      case DocumentType.passport:
        return 'passport';
      case DocumentType.driverLicense:
        return 'driver_license';
      case DocumentType.utilityBill:
        return 'utility_bill';
      case DocumentType.bankStatement:
        return 'bank_statement';
      case DocumentType.other:
        return 'other';
    }
  }

  // Méthodes utilitaires
  bool get isRemote => content is DocumentPath;
  bool get isLocal => content is DocumentBytes;

  String? get filePath => content is DocumentPath ? (content as DocumentPath).path : null;
  Uint8List? get bytes => content is DocumentBytes ? (content as DocumentBytes).data : null;
}
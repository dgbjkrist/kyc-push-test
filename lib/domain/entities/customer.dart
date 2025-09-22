import 'kyc.dart';
import 'kyc_document.dart';

class Customer {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String nationality;
  final String? status;
  final List<KycDocument> documents;
  final DateTime submittedAt;
  final bool isLocal;

  Customer({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.documents,
    required this.submittedAt,
    this.isLocal = false,
    this.status,
  });

  factory Customer.fromRemoteJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(), // ← Conversion en String
      fullName: json['full_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      nationality: json['nationality'],
      status: json['status'],
      documents: (json['documents'] as List?)
          ?.map((doc) => KycDocument.fromRemoteJson(doc))
          .toList() ?? [],
      submittedAt: DateTime.parse(json['submitted_at']),
      isLocal: false,
    );
  }

  factory Customer.fromLocalJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullName: json['fullName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nationality: json['nationality'],
      documents: (json['documents'] as List?)
          ?.map((doc) => KycDocument.fromLocalJson(doc))
          .toList() ?? [],
      submittedAt: DateTime.parse(json['createdAt']),
      isLocal: true,
    );
  }

  factory Customer.fromKycAndDocuments({
    required Kyc localKyc,
    required List<KycDocument> documents,
  }) {
    return Customer(
      id: localKyc.id,
      fullName: localKyc.fullName.value,
      dateOfBirth: DateTime.parse(localKyc.dateOfBirth.value),
      nationality: localKyc.nationality.value,
      documents: documents,
      submittedAt: localKyc.createdAt!,
      isLocal: true,
      status: 'pending',
    );
  }
}
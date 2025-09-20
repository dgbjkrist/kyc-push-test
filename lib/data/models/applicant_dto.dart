import '../../domain/entities/applicant.dart';

class ApplicantDto extends Applicant {
  ApplicantDto({
    required super.id,
    required super.tenantId,
    required super.userId,
    required super.referenceId,
    required super.fullName,
    required super.dateOfBirth,
    required super.nationality,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.submittedAt,
  });

  factory ApplicantDto.fromJson(Map<String, dynamic> json) {
    return ApplicantDto(
      id: json['id'],
      tenantId: json['tenant_id'],
      userId: json['user_id'],
      referenceId: json['reference_id'],
      fullName: json['full_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      nationality: json['nationality'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }
}

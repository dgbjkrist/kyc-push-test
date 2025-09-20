class Applicant {
  final int id;
  final int tenantId;
  final int userId;
  final String referenceId;
  final String fullName;
  final DateTime dateOfBirth;
  final String nationality;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime submittedAt;

  Applicant({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.referenceId,
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.submittedAt,
  });
}
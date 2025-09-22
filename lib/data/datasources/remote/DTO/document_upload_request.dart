class DocumentUploadRequest {
  final String applicantId;
  final String path;
  final String documentType;

  DocumentUploadRequest({
    required this.applicantId,
    required this.path,
    required this.documentType,
  });
}
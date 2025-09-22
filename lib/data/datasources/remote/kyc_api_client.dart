import 'dart:convert';
import 'dart:io';

import 'package:kyc/core/secure_storage/secure_storage.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';
import '../../../domain/entities/kyc.dart';
import '../../../http_client.dart';
import '../../models/applicant_dto.dart';
import 'DTO/document_upload_request.dart';

class KycApiClient {
  final HttpClient httpClient;
  final SecureStorage secureStorage;

  KycApiClient(this.httpClient, this.secureStorage);

  Future<Result<ApplicantDto>> createKycApplication(Kyc kyc) async {
    try {
      final body = {
        'full_name': kyc.fullName.value,
        'date_of_birth': kyc.dateOfBirth.value,
        'nationality': kyc.nationality.value,
      };
      final apiResponse = await httpClient.post('/api/kyc-applications',
        body: jsonEncode(body),
        idempotencyKey: kyc.id
      );

      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        final bodyDecoded = jsonDecode(apiResponse.data);
        final applicantDto = ApplicantDto.fromJson(bodyDecoded);
        return Success(applicantDto);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e) {
      return Failure(ServerError('Exception: $e'));
    }
  }

  Future<Result<void>> uploadDocument(DocumentUploadRequest documentUploadRequest,
      {required String idempotencyKey}) async {
    try {
      final apiResponse = await httpClient.uploadMultipart(
        '/kyc-applications/${documentUploadRequest.applicantId}/documents',
        fields: {'document_type': documentUploadRequest.documentType},
        files: [File(documentUploadRequest.path)],
        idempotencyKey: idempotencyKey,
      );
      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        return Success(null);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e) {
      return Failure(ServerError('Exception: $e'));
    }
  }
}
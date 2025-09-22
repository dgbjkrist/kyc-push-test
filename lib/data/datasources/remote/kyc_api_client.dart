import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:kyc/core/secure_storage/secure_storage.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';
import '../../../core/secure_storage/secure_file_storage.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/kyc.dart';
import '../../../http_client.dart';
import '../../models/applicant_dto.dart';
import '../../shared/paginated_response.dart';
import 'DTO/document_upload_request.dart';

class KycApiClient {
  final HttpClient httpClient;
  final SecureStorage secureStorage;
  final SecureFileStorage secureFileStorage;

  KycApiClient(this.httpClient, this.secureStorage, this.secureFileStorage);

  Future<Result<PaginatedResponse<Customer>>> getApplications() async {
    try {
      final apiResponse = await httpClient.get('/api/kyc-applications');

      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        // final bodyDecoded = jsonDecode(apiResponse.data);

        final applications = apiResponse.data['data']
            .map<Customer>((json) => Customer.fromRemoteJson(json))
            .toList();

        final PaginatedResponse<Customer> paginatedResponse = PaginatedResponse(
          items: applications,
          currentPage: apiResponse.data['current_page'],
          totalPages: apiResponse.data['last_page'],
          totalItems: apiResponse.data['total'],
          hasMore: apiResponse.data['current_page'] < apiResponse.data['last_page'],
        );

        return Success(paginatedResponse);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e) {
      return Failure(ServerError('Exception: $e'));
    }
  }

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
        final applicantDto = ApplicantDto.fromJson(apiResponse.data);
        return Success(applicantDto);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e, st) {
      print("KycApiClient createKycApplication error: $e\n$st");
      return Failure(ServerError('Exception: $e'));
    }
  }

  Future<Result<void>> uploadDocument(DocumentUploadRequest documentUploadRequest,
      {required String idempotencyKey, bool sync = false}) async {
    try {
      final Uint8List fileBytes;
      print("KycApiClient uploadDocument documentUploadRequest.path: ${documentUploadRequest.path}");
      print("KycApiClient uploadDocument sync: $sync");
      if (sync == true) {
        fileBytes = await secureFileStorage.readEncryptedFile(documentUploadRequest.path);
        // secureFileStorage.createTempFileFromBytes(fileBytes);
        // secureFileStorage.getFileExtensionFromMimeType(fileBytes);
        // print("KycApiClient uploadDocument fileBytes: ${fileBytes.length}");
      } else {
        print("KycApiClient uploadDocument file path: ");
        fileBytes = await File(documentUploadRequest.path).readAsBytes();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp${secureFileStorage.getFileExtension(fileBytes)}';
      final mimeType = secureFileStorage.getMimeTypeFromBytes(fileBytes);

      final apiResponse = await httpClient.uploadMultipart(
        '/api/kyc-applications/${documentUploadRequest.applicantId}/documents',
        documentType: documentUploadRequest.documentType,
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
        idempotencyKey: idempotencyKey,
      );
      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        return Success(null);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e, st) {
      print("KycApiClient uploadDocument error: $e\n$st");
      return Failure(ServerError('Exception: $e'));
    }
  }
}
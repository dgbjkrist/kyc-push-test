import 'package:kyc/core/errors/result_extensions.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/local/kyc_local_data_source.dart';
import '../datasources/remote/DTO/document_upload_request.dart';
import '../datasources/remote/kyc_api_client.dart';
import '../models/applicant_dto.dart';
import '../models/hive/kyc_local_model.dart';

class KycRepositoryImpl implements KycRepository {
  final KycLocalDataSource local;
  final KycApiClient remote;
  final NetworkInfo networkInfo;

  KycRepositoryImpl(this.networkInfo, this.local, this.remote);

  @override
  Future<Result<ApplicantDto?>> submitKyc(Kyc kyc) async {
    if (await networkInfo.isConnected) {
      Result<ApplicantDto> createApplicantResult = await remote.createKycApplication(kyc);
      return createApplicantResult.when(
        success: (applicant) async {
          final uploadResult = await _uploadAllDocuments(applicant.id.toString(), kyc);
          return uploadResult.when(
            success: (_) => Success(applicant),
            failure: (error) => Failure(error),
          );
        },
        failure: (error) => Failure(error),
      );
  } else {
      await local.savePending(kyc);
      return Success(null);
    }
    }

  @override
  Future<Result<ApplicantDto?>> retryPending() async {
    if (!await networkInfo.isConnected) return Failure(ServerError('No network connection'));
    final allPendingKyc = local.getAllPending();
    if (allPendingKyc.isEmpty) return Success(null);
    for (final pendingKyc in allPendingKyc) {
      try {
        final resultKyc = await submitKyc(pendingKyc);
        resultKyc.when(
          success: (applicant) async {
            await local.deletePending(pendingKyc.id);
          },
          failure: (error) => Failure(error),
        );
      } catch (e) {
        return Failure(AppError(e.toString()));
      }
    }
    return Success(null);
  }

  Future<Result<void>> _uploadAllDocuments(String applicantId, Kyc kyc) async {
    final documents = [
      _createDocumentRequest(applicantId, kyc.faceImagePath, 'selfie'),
      _createDocumentRequest(applicantId, kyc.cardRectoPath, 'passport'),
      if (kyc.cardVersoPath != null)
        _createDocumentRequest(applicantId, kyc.cardVersoPath!, 'double_sided'),
    ];

    for (final request in documents) {
      final result = await remote.uploadDocument(request, idempotencyKey: kyc.id);
      if (result is Failure) {
        return result;
      }
    }

    return Success(null);
  }

  DocumentUploadRequest _createDocumentRequest(
      String applicantId,
      String path,
      String documentType
      ) {
    return DocumentUploadRequest(
      applicantId: applicantId,
      path: path,
      documentType: documentType,
    );
  }
}

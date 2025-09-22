import 'package:kyc/core/result.dart';

import '../../core/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/local/kyc_local_data_source.dart';
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
      Result<ApplicantDto> createApplicantResult;
      createApplicantResult = await remote.createKycApplication(kyc);
      switch (createApplicantResult) {
        case Success(data: final applicant):
          await remote.uploadDocuments(applicant.id.toString(), kyc);
          return Success(createApplicantResult.data);
        case Failure(failure: final f):
          return Failure(f);
      }
  } else {
      final kycLocalModel = KycLocalModel(
        id: kyc.id,
        fullName: kyc.fullName.value,
        dateOfBirth: kyc.dateOfBirth.value,
        nationality: kyc.nationality.value,
        faceImagePath: kyc.faceImagePath,
        cardRectoPath: kyc.cardRectoPath,
        cardVersoPath: kyc.cardVersoPath,
        synced: false,
        createdAt: DateTime.now().toIso8601String(),
      );
      await local.savePending(kycLocalModel);
      return Success(null);
    }
    }

  @override
  Future<Result<ApplicantDto?>> retryPending() async {
    if (!await networkInfo.isConnected) return Failure(ServerError('No network connection'));
    final pending = local.getAllPending();
    for (final p in pending) {
      try {
        final result = await remote.createKycApplication(p);
        switch (result) {
          case Success(data: final applicant):
            await remote.uploadDocuments(applicant.id.toString(), p);
          case Failure(failure: final f):
            return Failure(f);
        }
        await local.deletePending(p.id);
        return Success(null);

      } catch (e) {
        return Failure(AppError(e.toString()));
      }
    }
    return Success(null);
  }
}

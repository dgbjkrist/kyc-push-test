import 'package:kyc/core/result.dart';

import '../../core/network/network_info.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/value_objects/date_of_birth.dart';
import '../../domain/value_objects/full_name.dart';
import '../../domain/value_objects/nationality.dart';
import '../datasources/local/kyc_local_data_source.dart';
import '../datasources/remote/kyc_api_client.dart';
import '../models/applicant_dto.dart';

class KycRepositoryImpl implements KycRepository {
  final KycLocalDataSource local;
  final KycApiClient remote;
  final NetworkInfo networkInfo;

  KycRepositoryImpl(this.networkInfo, this.local, this.remote);

  @override
  Future<Result<dynamic>> submitKyc(Kyc kyc) async {
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
      await local.savePending(kyc);
      return Success(null);
    }
    }

  @override
  Future<Result<dynamic>> retryPending() async {
    return Success(null);
    // if (!await networkInfo.isConnected) return;
    // final pending = local.getAllPending();
    // for (final p in pending) {
    //   try {
    //     final appId = await remote.createKycApplication(p);
    //     await remote.uploadDocuments(appId, p);
    //     await local.deletePending(p.id);
    //   } catch (e) {
    //     // keep for next retry
    //   }
    // }
  }
}

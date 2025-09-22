import '../../core/errors/result.dart';
import '../entities/kyc.dart';
import '../repositories/kyc_repository.dart';

class CreateKycUsecase {
  final KycRepository repository;

  CreateKycUsecase(this.repository);

  Future<Result<void>> execute(Kyc kyc) async {
    return await repository.submitKyc(kyc);
  }
}
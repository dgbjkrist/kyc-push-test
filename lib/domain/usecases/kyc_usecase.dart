import '../../core/errors/result.dart';
import '../entities/kyc.dart';
import '../repositories/kyc_repository.dart';

class KycUsecase {
  final KycRepository repository;

  KycUsecase(this.repository);

  Future<Result<void>> execute(Kyc kyc) async {
    return await repository.submitKyc(kyc);
  }
}
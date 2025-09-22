import 'package:kyc/core/errors/result.dart';

import '../entities/kyc.dart';

abstract class KycRepository {
  Future<Result<void>> submitKyc(Kyc kyc);
  Future<Result<void>> retryPending();
}
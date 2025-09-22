import 'package:kyc/core/errors/result.dart';

import '../entities/customer.dart';
import '../entities/kyc.dart';

abstract class KycRepository {
  Future<Result<List<Customer>>> getCustomers();
  Future<Result<void>> submitKyc(Kyc kyc);
  Future<Result<void>> retryPending();
  Result<void> deleteLocalApplication(String id);
}
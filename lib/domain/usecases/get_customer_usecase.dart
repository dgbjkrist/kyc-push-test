import '../../core/errors/result.dart';
import '../entities/customer.dart';
import '../repositories/kyc_repository.dart';

class GetCustomerUsecase {
  final KycRepository repository;

  GetCustomerUsecase(this.repository);

  Future<Result<List<Customer>>> execute() async {
    return await repository.getCustomers();
  }
}
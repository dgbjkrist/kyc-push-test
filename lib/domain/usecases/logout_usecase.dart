import 'package:kyc/core/errors/result.dart';

import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Result<Null>> execute() async {
    return await repository.logout();
  }
}

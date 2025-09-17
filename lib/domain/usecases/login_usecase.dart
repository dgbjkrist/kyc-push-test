import 'package:kyc/core/result.dart';

import '../entities/auth.dart';
import '../entities/user.dart';
import '../repositories/login_repository.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<Result<Auth>> execute({
    required String email,
    required String password,
  }) async {
    return await repository.login(email, password);
  }
}

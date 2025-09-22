import 'package:kyc/core/errors/result.dart';
import 'package:kyc/domain/value_objects/password.dart';

import '../entities/auth.dart';
import '../entities/user.dart';
import '../repositories/login_repository.dart';
import '../value_objects/email.dart';

class LoginUsecase {
  final LoginRepository repository;

  LoginUsecase(this.repository);

  Future<Result<Auth>> execute({
    required Email email,
    required Password password,
  }) async {
    return await repository.login(email, password);
  }
}

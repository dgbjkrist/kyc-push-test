import 'package:kyc/core/result.dart';
import 'package:kyc/domain/entities/auth.dart';
import 'package:kyc/domain/value_objects/email.dart';
import 'package:kyc/domain/value_objects/password.dart';

import '../../core/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/remote/login_api_service.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginApiService loginApiService;

  LoginRepositoryImpl(this.loginApiService);

  @override
  Future<Result<Auth>> login(Email email, Password password) async {
      final remoteResult = await loginApiService.login(email.value, password.value);
      switch (remoteResult) {
        case Success(data: final auth):
          return Success(auth);
        case Failure(failure: final f):
          return Failure(f);
      }
  }
}
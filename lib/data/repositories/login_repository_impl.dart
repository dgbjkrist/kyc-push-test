import 'package:kyc/core/errors/result_extensions.dart';
import 'package:kyc/domain/entities/auth.dart';
import 'package:kyc/domain/value_objects/email.dart';
import 'package:kyc/domain/value_objects/password.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
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
      return remoteResult.when(
        success: (auth) => Success(auth),
        failure: (error) => Failure(error),
      );
  }
}
import 'package:kyc/core/result.dart';
import 'package:kyc/domain/entities/auth.dart';

import '../../core/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/local/local_login_service.dart';
import '../datasources/remote/login_api_service.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginApiService loginApiService;
  final LocalLoginService localLoginService;
  final NetworkInfo networkInfo;

  LoginRepositoryImpl(this.loginApiService, this.localLoginService, this.networkInfo);

  @override
  Future<Result<Auth>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      final remoteResult = await loginApiService.login(email, password);
      switch (remoteResult) {
        case Success(data: final auth):
          await localLoginService.cacheAuth(auth);
          return Success(auth);
        case Failure(failure: final f):
          return Failure(f);
      }
    } else {
      final localResult = await localLoginService.getLastAuth();
      switch (localResult) {
        case Success(data: final auth):
          if (auth != null) return Success(auth);
          return const Failure(NetworkError("No internet and no cache"));
        case Failure(failure: final f):
          return Failure(f);
      }
    }
  }
}
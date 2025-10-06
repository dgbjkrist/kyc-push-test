import 'package:bloc/bloc.dart';
import 'package:kyc/domain/usecases/login_usecase.dart';
import 'package:kyc/domain/value_objects/password.dart';
import 'package:meta/meta.dart';
import '../../core/secure_storage/secure_storage.dart';

import '../../core/errors/result.dart';
import '../../domain/entities/auth.dart';
import '../../domain/value_objects/email.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _loginUseCase;
  final SecureStorage _secureStorage;
  LoginCubit(this._loginUseCase, this._secureStorage) : super(LoginInitial());

  Future<void> restoreSession() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        emit(LoginSuccess(Auth(token: token)));
      }
    } catch (_) {
      // ignore restore errors; remain in initial state
    }
  }

  Future<Result<Auth>> login({
    required Email email,
    required Password password,
  }) async {
    emit(LoginLoading());

    final resultLogin = await _loginUseCase.execute(
      email: email,
      password: password,
    );

    switch (resultLogin) {
      case Success(data: final auth):
        emit(LoginSuccess(auth));
        return Success(auth);
      case Failure(failure: final f):
        emit(LoginError(f.message));
        return Failure(f);
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:kyc/domain/usecases/login_usecase.dart';
import 'package:kyc/domain/value_objects/password.dart';
import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../../domain/entities/auth.dart';
import '../../domain/value_objects/email.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _loginUseCase;
  LoginCubit(this._loginUseCase) : super(LoginInitial());

  Future<void> login({
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
        case Failure(failure: final f):
          emit(LoginError(f.message));
      }
  }
}

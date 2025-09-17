import 'package:bloc/bloc.dart';
import 'package:kyc/domain/usecases/login_usecase.dart';
import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../../domain/entities/auth.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  LoginCubit(this._loginUseCase) : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
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

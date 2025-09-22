import 'package:bloc/bloc.dart';
import 'package:kyc/core/errors/result_extensions.dart';
import 'package:meta/meta.dart';

import '../../domain/usecases/logout_usecase.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUsecase logoutUsecase;
  LogoutCubit(this.logoutUsecase) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    final result = await logoutUsecase.execute();

      return result.when(
        success: (success) => emit(LogoutSuccess()),
        failure: (failure) => emit(LogoutError(failure.toString())),
      );
    }
}

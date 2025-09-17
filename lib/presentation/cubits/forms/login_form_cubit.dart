import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';

part 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(LoginFormStateInitial());

  void emailChanged(String value) {
    emit(LoginFormStateChanged(
      email: Email(value),
      password: state.password,
    ));
  }

  void passwordChanged(String value) {
    emit(LoginFormStateChanged(
      email: state.email,
      password: Password(value),
    ));
  }
}

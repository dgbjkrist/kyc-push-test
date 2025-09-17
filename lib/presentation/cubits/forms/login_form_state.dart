part of 'login_form_cubit.dart';

@immutable
sealed class LoginFormState {
  final Email email;
  final Password password;

  const LoginFormState({
    required this.email,
    required this.password,
  });

  bool get isValid => email.isValid && password.isValid;
}

final class LoginFormStateInitial extends LoginFormState {
   LoginFormStateInitial() : super(email: Email(''), password: Password(''));
}

final class LoginFormStateChanged extends LoginFormState {
  const LoginFormStateChanged({
    required Email email, required Password password
  }): super(email: email, password: password);
}
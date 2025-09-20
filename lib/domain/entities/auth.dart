import 'user.dart';

class Auth {
  final String? status;
  final String? message;
  final String? token;
  final User? user;

  Auth({this.status, this.message, this.token, this.user});
}
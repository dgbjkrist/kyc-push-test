import '../../domain/entities/auth.dart';

class AuthModel extends Auth {
  const AuthModel({
    required super.token,
    required super.userId,
    required super.email,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'userId': userId,
    'email': email,
  };
}

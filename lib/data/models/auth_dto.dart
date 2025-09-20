import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';

class AuthDto extends Auth {
  AuthDto({
    super.token,
    super.user,
  });

  factory AuthDto.fromJson(Map<String, dynamic> json) {
    return AuthDto(
      token: json['access_token'],
      user: User(
        id: json['user']['id']?.toString(),
        tenantId: json['user']['tenant_id']?.toString(),
        name: json['user']['name'],
        email: json['user']['email'],
        photo: json['user']['photo'],
      ),
    );
  }
}

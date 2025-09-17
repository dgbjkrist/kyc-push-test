import 'package:dio/dio.dart';

import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../../models/auth_model.dart';

class LoginApiService {
  final Dio dio;
  LoginApiService(this.dio);

  Future<Result<AuthModel>> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        return Success(AuthModel.fromJson(response.data));
      } else {
        return Failure(ServerError('Invalid status code ${response.statusCode}'));
      }
    } catch (e) {
      return Failure(ServerError('Exception: $e'));
    }
  }
}
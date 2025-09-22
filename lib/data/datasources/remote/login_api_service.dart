import 'dart:convert';
import 'dart:io';

import 'package:kyc/core/secure_storage/secure_storage.dart';

import '../../../core/errors/failures.dart';
import '../../../core/errors/result.dart';
import '../../../http_client.dart';
import '../../models/auth_dto.dart';

class LoginApiService {
  final HttpClient httpClient;
  final SecureStorage secureStorage;
  LoginApiService(this.httpClient, this.secureStorage);

  Future<Result<AuthDto>> login(String email, String password) async {
    try {
      final body = json.encode({
        'email': email,
        'password': password,
      });
      final apiResponse = await httpClient.post('/api/login',
          body: body);

      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        // final data = jsonDecode(apiResponse.data);
        final auth = AuthDto.fromJson(apiResponse.data);
        if (auth.token == null) return Failure(ServerError('Invalid token'));
        await secureStorage.saveToken(auth.token!);
        return Success(auth);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e, stackTrace) {
      print("LoginApiService login error: $e\n$stackTrace");
      return Failure(ServerError('Exception: $e'));
    }
  }
}
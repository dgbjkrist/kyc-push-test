import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kyc/core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../../models/auth_dto.dart';

class LoginApiService {
  final http.Client client;
  final SecureStorage secureStorage;
  LoginApiService(this.client, this.secureStorage);

  Future<Result<AuthDto>> login(String email, String password) async {
    try {
      final body = json.encode({
        'email': email,
        'password': password,
      });
      print("body ::: $body");
      final apiResponse = await client.post(
          Uri.parse('https://kyc.xpertbot.online/api/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body);

      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        print("apiResponse.body ::: ${apiResponse.body}");
        final data = jsonDecode(apiResponse.body);
        final auth = AuthDto.fromJson(data);
        if (auth.token == null) return Failure(ServerError('Invalid token'));
        await secureStorage.saveToken(auth.token!);
        return Success(auth);
      } else {
        print("apiResponse.body faillure ::: ${apiResponse.body}");
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e, st) {
      print("apiResponse.body faillure ::: ${e}");
      print("apiResponse.body faillure ::: ${st}");
      return Failure(ServerError('Exception: $e'));
    }
  }
}
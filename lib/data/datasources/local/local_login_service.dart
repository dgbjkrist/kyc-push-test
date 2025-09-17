import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/failures.dart';
import '../../../core/result.dart';
import '../../models/auth_model.dart';

const String CACHED_AUTH = "CACHED_AUTH";

class LocalLoginService {
  final SharedPreferences prefs;
  LocalLoginService(this.prefs);

  @override
  Future<Result<void>> cacheAuth(AuthModel auth) async {
    try {
      await prefs.setString(CACHED_AUTH, jsonEncode(auth.toJson()));
      return const Success(null);
    } catch (e) {
      return Failure(CacheError('Cache error: $e'));
    }
  }

  @override
  Future<Result<AuthModel?>> getLastAuth() async {
    try {
      final jsonString = prefs.getString(CACHED_AUTH);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return Success(AuthModel.fromJson(jsonMap));
      } else {
        return const Success(null);
      }
    } catch (e) {
      return Failure(CacheError('Read error: $e'));
    }
  }

  @override
  Future<Result<void>> clearAuth() async {
    try {
      await prefs.remove(CACHED_AUTH);
      return const Success(null);
    } catch (e) {
      return Failure(CacheError('Clear error: $e'));
    }
  }
}
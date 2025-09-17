import 'package:kyc/core/result.dart';
import 'package:kyc/domain/entities/auth.dart';

import '../entities/user.dart';

abstract class LoginRepository {
  Future<Result<Auth>> login(String email, String password);
}

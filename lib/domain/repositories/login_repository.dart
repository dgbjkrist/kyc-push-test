import 'package:kyc/core/errors/result.dart';
import 'package:kyc/domain/entities/auth.dart';
import 'package:kyc/domain/value_objects/password.dart';

import '../entities/user.dart';
import '../value_objects/email.dart';

abstract class LoginRepository {
  Future<Result<Auth>> login(Email email, Password password);
}

import 'failures.dart';
import 'result.dart';

extension ResultPatternMatching<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(KError failure) failure,
  }) {
    switch (this) {
      case Success(data: final data):
        return success(data);
      case Failure(failure: final error):
        return failure(error);
    }
  }

  void whenVoid({
    required void Function(T data) success,
    required void Function(KError failure) failure,
  }) {
    switch (this) {
      case Success(data: final data):
        success(data);
      case Failure(failure: final error):
        failure(error);
    }
  }
}
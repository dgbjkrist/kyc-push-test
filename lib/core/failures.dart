sealed class KError {
  final String message;
  const KError(this.message);
}

class AppError extends KError {
  const AppError(super.message);
}

class ServerError extends KError {
  const ServerError(super.message);
}

class CacheError extends KError {
  CacheError(super.message);
}

class NetworkError extends KError {
  const NetworkError(super.message);
}
sealed class AppError {
  final String message;
  const AppError(this.message);
}

class ServerError extends AppError {
  const ServerError(String msg) : super(msg);
}

class CacheError extends AppError {
  const CacheError(String msg) : super(msg);
}

class NetworkError extends AppError {
  const NetworkError(String msg) : super(msg);
}
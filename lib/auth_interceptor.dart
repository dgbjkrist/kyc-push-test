import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class AuthInterceptor implements Interceptor {

  bool _isRefreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // if (err.response?.statusCode == HttpStatus.unauthorized) {
    //   // if (_isRefreshing) {
    //     final completer = Completer<Response>();
    //     _queue.add(QueuedRequest(originalRequest, completer));
    //     completer.future.then((resp) => handler.resolve(resp)).catchError((e) => handler.reject(e));
    //     return;
    //   // }
    // }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // TODO: implement onResponse
  }
}
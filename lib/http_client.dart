import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'core/secure_storage/secure_storage.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class HttpClient {
  final Dio _dio;
  final SecureStorage _storage;

  HttpClient({required List<String> certificatePins, required SecureStorage storage})
      : _storage = storage ,_dio = Dio(BaseOptions(
    baseUrl: 'https://kyc.xpertbot.online',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    _dio.interceptors.add(CertificatePinningInterceptor(
      allowedSHAFingerprints: certificatePins,
      timeout: 10,
    ));

    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
    ));
    _setupDefaultHeaders();
    _loadStoredToken();
  }

  void _setupDefaultHeaders() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<void> _loadStoredToken() async {
    final token = await _storage.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void updateBearerToken(String? newToken) {
    if (newToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $newToken';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? customHeaders,
  }) async {
    final options = Options(headers: customHeaders);
    return await _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? customHeaders,
    String? idempotencyKey,
  }) async {
    print("Idempotency-Key: $idempotencyKey");
    final headers = {...?customHeaders};
    if (idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final options = Options(headers: headers);
    return await _dio.post(endpoint, data: body, options: options);
  }

  Future<Response> uploadMultipart(
    String endpoint, {
    required String documentType,
    required Uint8List fileBytes,
        required String fileName,
        required String mimeType,
    Map<String, String>? customHeaders,
    String? idempotencyKey,
  }) async {
    final formData = FormData();
    final multipartFile = MultipartFile.fromBytes(
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );

    formData.fields.add(MapEntry('document_type', documentType));
    formData.files.add(MapEntry('file', multipartFile));

    final headers = {
      ...?customHeaders,
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };

    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(headers: headers, contentType: 'multipart/form-data'),
    );
  }
}

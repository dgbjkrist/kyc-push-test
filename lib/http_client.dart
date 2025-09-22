import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

import 'certificate_pinning_interceptor.dart';
import 'core/secure_storage/secure_storage.dart';

class HttpClient {
  final Dio _dio;
  final SecureStorage _storage;

  HttpClient({required List<String> certificatePins, required SecureStorage storage})
      : _dio = CertificatePinningInterceptor(certificatePins).createDioWithPinning(),
        _storage = storage
  {
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

  // Méthode pour mettre à jour le token
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
    final headers = {...?customHeaders};
    if (idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final options = Options(headers: headers);
    return await _dio.post(
      endpoint,
      data: body,
      options: options,
    );
  }

  // UPLOAD de fichiers multipart/form-data
  Future<Response> uploadMultipart(
      String endpoint, {
        required Map<String, dynamic> fields,
        required List<File> files,
        String fileFieldName = 'files',
        Map<String, String>? customHeaders,
        String? idempotencyKey,
      }) async {
    final formData = FormData();

    // Ajouter les champs texte
    fields.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    // Ajouter les fichiers
    for (final file in files) {
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      formData.files.add(MapEntry(
        fileFieldName,
        MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'),
        ),
      ));
    }

    // Préparer les headers
    final headers = {
      ...?customHeaders,
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };

    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        headers: headers,
        contentType: 'multipart/form-data',
      ),
    );
  }
}
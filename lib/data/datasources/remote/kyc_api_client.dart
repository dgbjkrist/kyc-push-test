import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kyc/core/result.dart';
import 'package:kyc/core/storage/secure_storage.dart';

import '../../../core/failures.dart';
import '../../../domain/entities/kyc.dart';
import '../../models/applicant_dto.dart';

class KycApiClient {
  final http.Client client;
  final SecureStorage secureStorage;

  KycApiClient(this.client, this.secureStorage);

  Future<Result<ApplicantDto>> createKycApplication(Kyc kyc) async {
    try {
      final url = Uri.parse('/kyc-applications');
      final authToken = await secureStorage.getToken();
      final body = {
        'full_name': kyc.fullName.value,
        'date_of_birth': kyc.dateOfBirth.value,
        'nationality': kyc.nationality.value,
      };
      final apiResponse = await client.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (apiResponse.statusCode == HttpStatus.ok || apiResponse.statusCode == HttpStatus.created) {
        final bodyDecoded = jsonDecode(apiResponse.body);
        final applicantDto = ApplicantDto.fromJson(bodyDecoded);
        return Success(applicantDto);
      } else {
        return Failure(ServerError('Invalid status code ${apiResponse.statusCode}'));
      }
    } catch (e) {
      return Failure(ServerError('Exception: $e'));
    }
  }

  Future<void> uploadDocuments(String appId, Kyc kyc) async {
    final url = Uri.parse('/kyc-applications/$appId/documents');
    final authToken = await secureStorage.getToken();
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $authToken';
    request.files.add(await http.MultipartFile.fromPath('files', kyc.faceImagePath));
    request.files.add(await http.MultipartFile.fromPath('files', kyc.cardRectoPath));
    if (kyc.cardVersoPath != null) request.files.add(await http.MultipartFile.fromPath('files', kyc.cardVersoPath!));

    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload docs failed: ${response.statusCode}');
    }
  }
}
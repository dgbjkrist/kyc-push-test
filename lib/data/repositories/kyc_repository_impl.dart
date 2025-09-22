import 'package:flutter/material.dart';
import 'package:kyc/core/errors/result_extensions.dart';
import 'package:kyc/domain/entities/customer.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/result.dart';
import '../../core/network/network_info.dart';
import '../../core/secure_storage/secure_file_storage.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/entities/kyc_document.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/local/kyc_local_data_source.dart';
import '../datasources/remote/DTO/document_upload_request.dart';
import '../datasources/remote/kyc_api_client.dart';
import '../models/applicant_dto.dart';
import '../models/hive/kyc_local_model.dart';

class KycRepositoryImpl implements KycRepository {
  final KycLocalDataSource local;
  final KycApiClient remote;
  final NetworkInfo networkInfo;
  final SecureFileStorage secureFileStorage;

  KycRepositoryImpl(this.networkInfo, this.local, this.remote, this.secureFileStorage);

  @override
  Future<Result<List<Customer>>> getCustomers() async {
    try {
      final [localCustomersResult, remoteCustomersResult] = await Future.wait([
        getLocalCustomers(),
        getRemoteCustomers(),
      ]);

      final localCustomers = localCustomersResult.when(
        success: (data) => data,
        failure: (error) => null,
      );

      final remoteCustomers = remoteCustomersResult.when(
        success: (data) => data,
        failure: (error) => null,
      );

      final allCustomers = _mergeAndSortApplications(localCustomers, remoteCustomers);
      return Success(allCustomers);
    } catch (e) {
      return Failure(AppError('Failed to load customers: $e'));
    }
  }

  Future<List<KycDocument>> _loadLocalDocuments(Kyc localKyc) async {
    final List<KycDocument> documents = [];

    try {
      final faceBytes = await secureFileStorage.readEncryptedFile(localKyc.faceImagePath);
      documents.add(KycDocument.fromBytesWithStringType(
        type: 'selfie',
        bytes: faceBytes,
      ));

      final rectoBytes = await secureFileStorage.readEncryptedFile(localKyc.cardRectoPath);
      documents.add(KycDocument.fromBytesWithStringType(
        type: 'identity_card',
        bytes: rectoBytes,
      ));

      if (localKyc.cardVersoPath != null) {
        final versoBytes = await secureFileStorage.readEncryptedFile(localKyc.cardVersoPath!);
        documents.add(KycDocument.fromBytesWithStringType(
          type: 'identity_card',
          bytes: versoBytes,
        ));
      }

    } catch (e) {
      debugPrint('Erreur lors du chargement des documents locaux: $e');
    }

    return documents;
  }

  Future<Result<List<Customer>>> getRemoteCustomers() async {
    try {
      final getCustomersResult = await remote.getApplications();
      return getCustomersResult.when(
        success: (remoteKycs) => Success(remoteKycs.items),
        failure: (error) => Failure(error),
      );
    } catch (e) {
      return Failure(AppError('Failed to load remote applications: $e'));
    }
  }

  Future<Result<List<Customer>>> getLocalCustomers() async {
    try {
      final localKycs = await local.getAllPending();
      final List<Customer> customers = [];

      for (final localKyc in localKycs) {
        // Charger les images décryptées
        final documents = await _loadLocalDocuments(localKyc);

        final customer = Customer.fromKycAndDocuments(
          localKyc: localKyc,
          documents: documents,
        );

        customers.add(customer);
      }

      return Success(customers);
    } catch (e) {
      return Failure(AppError('Failed to load local applications: $e'));
    }
  }

  List<Customer> _mergeAndSortApplications(
      List<Customer>? localCustomers,
      List<Customer>? remoteCustomers,
      ) {

    final allCustomers = [
      ...?localCustomers,
      ...?remoteCustomers,
    ];

    allCustomers.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return allCustomers;
  }

  @override
  Future<Result<ApplicantDto?>> submitKyc(Kyc kyc, {bool sync = false}) async {
    if (await networkInfo.isConnected) {
      Result<ApplicantDto> createApplicantResult = await remote.createKycApplication(kyc);
      return createApplicantResult.when(
        success: (applicant) async {
          final uploadResult = await _uploadAllDocuments(applicant.id.toString(), kyc, sync);
          return uploadResult.when(
            success: (_) => Success(applicant),
            failure: (error) => Failure(error),
          );
        },
        failure: (error) => Failure(error),
      );
  } else {
      await local.savePending(kyc);
      return Success(null);
    }
    }

  @override
  Future<Result<ApplicantDto?>> retryPending() async {
    if (!await networkInfo.isConnected) return Failure(ServerError('No network connection'));
    final allPendingKyc = await local.getAllPending();
    if (allPendingKyc.isEmpty) return Success(null);
    for (final pendingKyc in allPendingKyc) {
      try {
        final resultKyc = await submitKyc(pendingKyc, sync: true);
        resultKyc.when(
          success: (applicant) async {
            await local.deletePending(pendingKyc.id);
          },
          failure: (error) => Failure(error),
        );
      } catch (e) {
        return Failure(AppError(e.toString()));
      }
    }
    return Success(null);
  }

  Future<Result<void>> _uploadAllDocuments(String applicantId, Kyc kyc, bool sync) async {
    final documents = [
      _createDocumentRequest(applicantId, kyc.faceImagePath, 'selfie'),
      _createDocumentRequest(applicantId, kyc.cardRectoPath, 'passport'),
      if (kyc.cardVersoPath != null)
        _createDocumentRequest(applicantId, kyc.cardVersoPath!, 'double_sided'),
    ];

    for (final request in documents) {
      final result = await remote.uploadDocument(request, idempotencyKey: kyc.id, sync: sync);
      if (result is Failure) {
        return result;
      }
    }

    return Success(null);
  }

  DocumentUploadRequest _createDocumentRequest(
      String applicantId,
      String path,
      String documentType
      ) {
    return DocumentUploadRequest(
      applicantId: applicantId,
      path: path,
      documentType: documentType,
    );
  }

  @override
  Result<Null> deleteLocalApplication(String id) {
    local.deletePending(id);
    return Success(null);
  }
}

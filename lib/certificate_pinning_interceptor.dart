import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart' show ASN1Parser, ASN1Sequence, ASN1BitString;
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:crypto/crypto.dart';

class CertificatePinningInterceptor {
  final List<String> allowedBase64Pins;

  CertificatePinningInterceptor(this.allowedBase64Pins);

  Dio createDioWithPinning() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://kyc.xpertbot.online',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      return HttpClient(context: SecurityContext.defaultContext)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // ⚡ Ici tu reçois TOUS les certificats (valides ou non)
          return _validateCertificate(cert);
        };
    };

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    return dio;
  }

  bool _validateCertificate(X509Certificate cert) {
    try {
      print('Certificate: ${cert}');
      // Extraire la clé publique du certificat
      final publicKey = _extractPublicKeyFromCertificate(cert.der);

      // Calculer l'empreinte
      final hash = sha256.convert(publicKey).bytes;
      final base64Hash = base64.encode(hash);

      print('Certificate pin: $base64Hash');
      print('Allowed pins: $allowedBase64Pins');
      print('Certificate pin matches: ${allowedBase64Pins.contains(base64Hash)}');

      // Comparer avec les pins autorisés
      return allowedBase64Pins.contains(base64Hash);
    } catch (e) {
      return false;
    }
  }

  Uint8List _extractPublicKeyFromCertificate(Uint8List derBytes) {
    // Parser le certificat DER
    print('Certificate DER: ${derBytes.length} bytes');
    final asn1Parser = ASN1Parser(derBytes);
    final sequence = asn1Parser.nextObject() as ASN1Sequence;

    // Le certificat est une séquence, la première partie est le TBSCertificate
    final tbsCertificate = sequence.elements[0] as ASN1Sequence;

    // Le SubjectPublicKeyInfo est généralement le 6ème élément du TBSCertificate
    final subjectPublicKeyInfo = tbsCertificate.elements[6] as ASN1Sequence;

    // La clé publique est le 1er élément du SubjectPublicKeyInfo
    final publicKeyBitString = subjectPublicKeyInfo.elements[1] as ASN1BitString;

    return publicKeyBitString.contentBytes();
  }
}
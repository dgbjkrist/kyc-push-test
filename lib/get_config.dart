import 'dart:convert';

import 'package:flutter/services.dart';

class GetConfig {
  static late Map<String, dynamic> _config;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final configString = await rootBundle.loadString('assets/config/config.json');
      _config = json.decode(configString) as Map<String, dynamic>;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load configuration: $e');
    }
  }

  static List<String> getCertificatePins() {
    _checkInitialized();
    return List<String>.from(_config['certificate_pins']);
  }

  static void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('Config not initialized. Call initialize() first.');
    }
  }
}
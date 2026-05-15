import 'package:flutter/foundation.dart';

class AppConfig {
  // Toggle this to false for production
  static const bool isDevelopment = kDebugMode;

  // Development Settings
  static const String devHost = '127.0.0.1'; // Use '10.0.2.2' for Emulator
  static const String devPort = '3000';
  
  // Production Settings (Replace with your real production domain)
  static const String prodHost = 'api.mhmandalraipur.org';
  static const String prodProtocol = 'https';

  static String get apiBaseUrl {
    if (isDevelopment) {
      return 'http://$devHost:$devPort/api/v1';
    } else {
      return '$prodProtocol://$prodHost/api/v1';
    }
  }

  static String get apiHost => isDevelopment ? devHost : prodHost;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

 
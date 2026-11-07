import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String _defaultEquranBaseUrl = 'https://equran.id/api/v2';
  static const String _defaultAladhanBaseUrl = 'https://api.aladhan.com/v1';

  static String get equranBaseUrl =>
      _env('EQURAN_API_BASE_URL', _defaultEquranBaseUrl);

  static String get aladhanBaseUrl =>
      _env('ALADHAN_API_BASE_URL', _defaultAladhanBaseUrl);

  static String _env(String key, String fallback) {
    final value = dotenv.env[key];
    return value == null || value.isEmpty ? fallback : value;
  }
}

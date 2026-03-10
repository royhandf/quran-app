import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get quranBaseUrl => dotenv.env['QURAN_API_BASE_URL']!;

  static String get aladhanBaseUrl => dotenv.env['ALADHAN_API_BASE_URL']!;

  static String get audioCdnBaseUrl => dotenv.env['AUDIO_CDN_BASE_URL']!;
}

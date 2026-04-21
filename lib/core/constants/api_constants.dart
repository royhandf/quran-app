import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get equranBaseUrl => dotenv.env['EQURAN_API_BASE_URL']!;

  static String get aladhanBaseUrl => dotenv.env['ALADHAN_API_BASE_URL']!;
}


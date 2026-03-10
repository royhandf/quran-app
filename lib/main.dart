import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quran_app/core/services/notification_service.dart';
import 'app/app.dart';
import 'core/di/injection.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await HiveService.init();
  await NotificationService.init();
  configureDependencies();
  runApp(const QuranApp());
}

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/di/injection.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  configureDependencies();
  runApp(const QuranApp());
}

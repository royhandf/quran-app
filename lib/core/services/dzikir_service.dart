import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/dzikir.dart';

class DzikirService {
  static List<DzikirCategory>? _cache;

  static Future<List<DzikirCategory>> loadCategories() async {
    if (_cache != null) return _cache!;

    final results = await Future.wait([
      rootBundle.loadString('assets/data/dzikir_pagi.json'),
      rootBundle.loadString('assets/data/dzikir_petang.json'),
    ]);

    final pagiItems = (json.decode(results[0]) as List)
        .map((e) => DzikirItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final petangItems = (json.decode(results[1]) as List)
        .map((e) => DzikirItem.fromJson(e as Map<String, dynamic>))
        .toList();

    _cache = [
      DzikirCategory(
        id: 'pagi',
        title: 'Dzikir Pagi',
        subtitle: 'Dibaca setelah Subuh',
        icon: 'wb_sunny',
        items: pagiItems,
      ),
      DzikirCategory(
        id: 'petang',
        title: 'Dzikir Petang',
        subtitle: 'Dibaca setelah Ashar',
        icon: 'nights_stay',
        items: petangItems,
      ),
    ];

    return _cache!;
  }
}

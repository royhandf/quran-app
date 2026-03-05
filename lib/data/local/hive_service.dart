import 'package:hive_flutter/hive_flutter.dart';
import '../models/bookmark.dart';

class HiveService {
  static const String bookmarkBox = 'bookmark';
  static const String settingsBox = 'settings';
  static const String lastReadKey = 'last_read';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(bookmarkBox);
    await Hive.openBox(settingsBox);
  }

  Box<Map> get _bookmarkBox => Hive.box<Map>(bookmarkBox);
  Box get _settingsBox => Hive.box(settingsBox);

  // Bookmarks
  List<Bookmark> getBookmarks() =>
      _bookmarkBox.values.map((map) => Bookmark.fromMap(map)).toList();

  Future<void> addBookmark(Bookmark bookmark) async =>
      await _bookmarkBox.put(bookmark.id, bookmark.toMap());

  Future<void> removeBookmark(String id) async => await _bookmarkBox.delete(id);

  bool isBookmarked(String id) => _bookmarkBox.containsKey(id);

  // Last Read
  Map<String, dynamic>? getLastRead() {
    final data = _settingsBox.get(lastReadKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> saveLastRead({
    required int surahId,
    required String surahName,
    required int ayahNumber,
  }) async {
    await _settingsBox.put(lastReadKey, {
      'surahId': surahId,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Settings
  Map<String, dynamic> getAllSettings() {
    final Map<String, dynamic> result = {};
    for (final key in _settingsBox.keys) {
      if (key != lastReadKey) result[key.toString()] = _settingsBox.get(key);
    }
    return result;
  }

  Future<void> saveSetting(String key, dynamic value) async =>
      await _settingsBox.put(key, value);
}

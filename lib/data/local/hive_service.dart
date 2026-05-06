import 'package:hive_flutter/hive_flutter.dart';
import '../models/bookmark.dart';
import '../models/prayer_time.dart';
import '../../presentation/blocs/prayer/prayer_state.dart';

class HiveService {
  static const String bookmarkBox = 'bookmark';
  static const String settingsBox = 'settings';
  static const String lastReadKey = 'last_read';
  static const String alarmBox = 'prayer_alarms';
  static const String versesBox = 'quran_verses';
  static const String _prayerCacheKey = 'cached_prayer';
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(bookmarkBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox<bool>(alarmBox);
    await Hive.openBox<List>(versesBox);
  }

  Box<List> get _versesBox => Hive.box<List>(versesBox);
  Box<Map> get _bookmarkBox => Hive.box<Map>(bookmarkBox);
  Box<bool> get _alarmBox => Hive.box<bool>(alarmBox);
  Box get _settingsBox => Hive.box(settingsBox);

  List<Bookmark> getBookmarks() =>
      _bookmarkBox.values.map((map) => Bookmark.fromMap(map)).toList();

  Future<void> addBookmark(Bookmark bookmark) async =>
      await _bookmarkBox.put(bookmark.id, bookmark.toMap());

  Future<void> removeBookmark(String id) async => await _bookmarkBox.delete(id);

  bool isBookmarked(String id) => _bookmarkBox.containsKey(id);
  bool isAlarmEnabled(String prayerName) =>
      _alarmBox.get(prayerName, defaultValue: true) ?? true;

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

  Future<void> clearLastRead() async {
    await _settingsBox.delete(lastReadKey);
  }

  Future<void> saveVerses(
    int surahId,
    List<Map<String, dynamic>> verses,
  ) async {
    await _versesBox.put(surahId, verses);
  }

  List<Map<String, dynamic>>? getVerses(int surahId) {
    final data = _versesBox.get(surahId);
    if (data == null) return null;
    return data.cast<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<void> setAlarmEnabled(String prayerName, bool enabled) async =>
      await _alarmBox.put(prayerName, enabled);

  Map<String, bool> getAllAlarms() => Map.fromEntries(
    _alarmBox.toMap().entries.map((e) => MapEntry(e.key.toString(), e.value)),
  );

  Map<String, dynamic> getAllSettings() {
    final Map<String, dynamic> result = {};
    for (final key in _settingsBox.keys) {
      if (key != lastReadKey) result[key.toString()] = _settingsBox.get(key);
    }
    return result;
  }

  Future<void> saveSetting(String key, dynamic value) async =>
      await _settingsBox.put(key, value);

  int getPrayerMethod() =>
      _settingsBox.get('prayerMethod', defaultValue: 20) as int;
  Future<void> setPrayerMethod(int method) =>
      saveSetting('prayerMethod', method);

  int getPrayerSchool() =>
      _settingsBox.get('prayerSchool', defaultValue: 0) as int;
  Future<void> setPrayerSchool(int school) =>
      saveSetting('prayerSchool', school);

  int getHijriAdjustment() =>
      _settingsBox.get('hijriAdjustment', defaultValue: 0) as int;
  Future<void> setHijriAdjustment(int adj) =>
      saveSetting('hijriAdjustment', adj);

  bool getUse12HourFormat() =>
      _settingsBox.get('use12HourFormat', defaultValue: false) as bool;
  Future<void> setUse12HourFormat(bool v) => saveSetting('use12HourFormat', v);

  bool isSurahDownloaded(int surahId) => _versesBox.containsKey(surahId);
  Future<void> deleteVerses(int surahId) async {
    await _versesBox.delete(surahId);
  }

  Set<int> getDownloadedSurahIds() {
    return _versesBox.keys.cast<int>().toSet();
  }

  void cachePrayerData(PrayerLoaded data) {
    _settingsBox.put(_prayerCacheKey, {
      'imsak': data.prayerTime.imsak,
      'fajr': data.prayerTime.fajr,
      'dhuhr': data.prayerTime.dhuhr,
      'asr': data.prayerTime.asr,
      'maghrib': data.prayerTime.maghrib,
      'isha': data.prayerTime.isha,
      'sunrise': data.prayerTime.sunrise,
      'date': data.prayerTime.date,
      'hijriDate': data.prayerTime.hijriDate,
      'qibla': data.qiblaDirection,
      'cityName': data.locationName,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  PrayerLoaded? getCachedPrayerData() {
    final raw = _settingsBox.get(_prayerCacheKey);
    if (raw == null || raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);

    final cachedAt = DateTime.tryParse(map['cachedAt'] ?? '');
    if (cachedAt == null) return null;
    final now = DateTime.now();
    if (cachedAt.year != now.year ||
        cachedAt.month != now.month ||
        cachedAt.day != now.day) {
      return null;
    }

    return PrayerLoaded(
      prayerTime: PrayerTime(
        imsak: map['imsak'] ?? '',
        fajr: map['fajr'] ?? '',
        dhuhr: map['dhuhr'] ?? '',
        asr: map['asr'] ?? '',
        maghrib: map['maghrib'] ?? '',
        isha: map['isha'] ?? '',
        sunrise: map['sunrise'] ?? '',
        date: map['date'] ?? '',
        hijriDate: map['hijriDate'] ?? '',
      ),
      qiblaDirection: map['qibla'] as double?,
      locationName: map['cityName'] ?? '',
    );
  }
}

import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/juz.dart';
import '../local/hive_service.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class QuranRepository {
  final ApiService _apiService;
  final HiveService _hiveService;

  QuranRepository(this._apiService, this._hiveService);

  Future<List<Surah>> getSurahs() async {
    final response = await _apiService.get(
      '${ApiConstants.quranBaseUrl}/chapters',
      params: {'language': 'id'},
    );
    final List chapters = response.data['chapters'];
    return chapters.map((json) => Surah.fromJson(json)).toList();
  }

  Future<List<Ayah>> getVerses(int surahId) async {
    final local = _hiveService.getVerses(surahId);
    if (local != null) {
      return local.map((json) => Ayah.fromJson(json)).toList();
    }
    return _fetchVersesFromApi(surahId);
  }

  Future<List<Ayah>> downloadSurah(int surahId) async {
    final verses = await _fetchVersesFromApi(surahId);
    final jsonList = verses.map((a) => a.toJson()).toList();
    await _hiveService.saveVerses(surahId, jsonList);
    return verses;
  }

  Future<void> deleteSurah(int surahId) async {
    await _hiveService.deleteVerses(surahId);
  }

  bool isSurahDownloaded(int surahId) =>
      _hiveService.isSurahDownloaded(surahId);

  Set<int> getDownloadedSurahIds() => _hiveService.getDownloadedSurahIds();

  Future<List<Ayah>> _fetchVersesFromApi(int surahId) async {
    final response = await _apiService.get(
      '${ApiConstants.quranBaseUrl}/verses/by_chapter/$surahId',
      params: {
        'language': 'id',
        'translations': '33',
        'fields': 'text_uthmani,text_imlaei',
        'per_page': 300,
      },
    );
    final List verses = response.data['verses'];
    return verses.map((json) => Ayah.fromJson(json)).toList();
  }

  Future<List<Juz>> getJuzs() async {
    final response = await _apiService.get('${ApiConstants.quranBaseUrl}/juzs');
    final List juzs = response.data['juzs'];
    final all = juzs.map((json) => Juz.fromJson(json)).toList();
    final seen = <int>{};
    return all.where((j) => seen.add(j.juzNumber)).toList();
  }

  Future<List<Ayah>> getVersesByJuz(int juzNumber) async {
    final response = await _apiService.get(
      '${ApiConstants.quranBaseUrl}/verses/by_juz/$juzNumber',
      params: {
        'language': 'id',
        'translations': '33',
        'fields': 'text_uthmani,text_imlaei',
        'per_page': 300,
      },
    );
    final List verses = response.data['verses'];
    return verses.map((json) => Ayah.fromJson(json)).toList();
  }
}

import '../models/surah.dart';
import '../models/ayah.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class QuranRepository {
  final ApiService _apiService;
  QuranRepository(this._apiService);

  Future<List<Surah>> getSurahs() async {
    final response = await _apiService.get(
      '${ApiConstants.quranBaseUrl}/chapters',
      params: {'language': 'id'},
    );
    final List chapters = response.data['chapters'];
    return chapters.map((json) => Surah.fromJson(json)).toList();
  }

  Future<List<Ayah>> getVerses(int surahId) async {
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
}

import '../models/surah.dart';
import '../models/ayah.dart';
import '../local/hive_service.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

const _reciterFolders = {
  '01': 'Abdullah-Al-Juhany',
  '02': 'Abdul-Muhsin-Al-Qasim',
  '03': 'Abdurrahman-as-Sudais',
  '04': 'Ibrahim-Al-Dossari',
  '05': 'Misyari-Rasyid-Al-Afasi',
  '06': 'Yasser-Al-Dosari',
};

class QuranRepository {
  final ApiService _apiService;
  final HiveService _hiveService;

  QuranRepository(this._apiService, this._hiveService);

  Future<List<Surah>> getSurahs() async {
    final response = await _apiService.get(
      '${ApiConstants.equranBaseUrl}/surat',
    );
    final List surahs = response.data['data'];
    return surahs.map((json) => Surah.fromEquranJson(json)).toList();
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
      '${ApiConstants.equranBaseUrl}/surat/$surahId',
    );
    final List ayat = response.data['data']['ayat'];
    return ayat.map((json) => Ayah.fromEquranJson(json)).toList();
  }

  Future<Map<String, String>> getChapterAudioFiles(
    int surahId,
    int reciterId,
  ) async {
    final reciterKey = reciterId.clamp(1, 6).toString().padLeft(2, '0');
    final folder = _reciterFolders[reciterKey] ?? _reciterFolders['05']!;
    final surahStr = surahId.toString().padLeft(3, '0');

    int versesCount;
    final cached = _hiveService.getVerses(surahId);
    if (cached != null && cached.isNotEmpty) {
      versesCount = cached.length;
    } else {
      final resp = await _apiService.get(
        '${ApiConstants.equranBaseUrl}/surat/$surahId',
      );
      versesCount = resp.data['data']['jumlahAyat'] as int;
    }

    return {
      for (int ayah = 1; ayah <= versesCount; ayah++)
        '$surahId:$ayah':
            'https://cdn.equran.id/audio-partial/$folder/$surahStr${ayah.toString().padLeft(3, '0')}.mp3',
    };
  }
}

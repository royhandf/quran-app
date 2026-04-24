import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/surah.dart';
import '../../../data/repositories/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _repository;
  QuranRepository get repository => _repository;
  List<Surah> _allSurahs = [];

  List<Surah> get allSurahs => _allSurahs;

  Surah? findSurahById(int id) {
    try {
      return _allSurahs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  QuranCubit(this._repository) : super(QuranInitial());

  Future<void> loadSurahs() async {
    emit(QuranLoading());
    try {
      _allSurahs = await _repository.getSurahs();
      final downloadedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  Future<void> downloadSurah(int surahId) async {
    final downloadedIds = _repository.getDownloadedSurahIds();
    emit(SurahsLoaded(_allSurahs,
        downloadedIds: downloadedIds, downloadingSurahId: surahId));
    try {
      await _repository.downloadSurah(surahId);
      final updatedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: updatedIds));
    } catch (e) {
      final updatedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs,
          downloadedIds: updatedIds,
          errorMessage: 'Gagal download: ${e.toString()}'));
    }
  }

  Future<void> downloadSurahSilent(int surahId) async {
    await _repository.downloadSurah(surahId);
  }

  void refreshDownloadStatus() {
    if (_allSurahs.isNotEmpty) {
      final downloadedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
    }
  }

  Future<void> deleteSurah(int surahId) async {
    await _repository.deleteSurah(surahId);
    final downloadedIds = _repository.getDownloadedSurahIds();
    emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
  }

  Future<void> loadVerses(Surah surah) async {
    emit(QuranLoading());
    try {
      var verses = await _repository.getVerses(surah.id);
      if (verses.isNotEmpty &&
          verses.every((v) => v.textTransliteration == null)) {
        verses = await _repository.downloadSurah(surah.id);
      }
      emit(VersesLoaded(surah: surah, verses: verses));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  void restoreSurahList() {
    if (_allSurahs.isNotEmpty) {
      final downloadedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
    }
  }

  void searchSurahs(String query) {
    if (query.isEmpty) {
      final downloadedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
      return;
    }
    final filtered = _allSurahs
        .where(
          (s) =>
              s.nameSimple.toLowerCase().contains(query.toLowerCase()) ||
              s.translatedName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final downloadedIds = _repository.getDownloadedSurahIds();
    emit(SurahsLoaded(filtered, downloadedIds: downloadedIds));
  }
}

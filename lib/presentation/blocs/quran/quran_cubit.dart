import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/surah.dart';
import '../../../data/models/juz.dart';
import '../../../data/repositories/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _repository;
  QuranRepository get repository => _repository;
  List<Surah> _allSurahs = [];

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
    try {
      await _repository.downloadSurah(surahId);
      final downloadedIds = _repository.getDownloadedSurahIds();
      emit(SurahsLoaded(_allSurahs, downloadedIds: downloadedIds));
    } catch (e) {
      emit(QuranError('Gagal download: ${e.toString()}'));
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
      final verses = await _repository.getVerses(surah.id);
      emit(VersesLoaded(surah: surah, verses: verses));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  Future<void> loadJuzs() async {
    emit(QuranLoading());
    try {
      final results = await Future.wait([
        _repository.getJuzs(),
        _allSurahs.isEmpty ? _repository.getSurahs() : Future.value(_allSurahs),
      ]);

      final juzs = results[0] as List<Juz>;
      final surahs = results[1] as List<Surah>;

      if (_allSurahs.isEmpty) _allSurahs = surahs;

      final surahNames = {for (final s in surahs) s.id: s.nameSimple};

      emit(JuzsLoaded(juzs: juzs, surahNames: surahNames));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  Future<void> loadVersesByJuz(int juzNumber) async {
    emit(QuranLoading());
    try {
      final verses = await _repository.getVersesByJuz(juzNumber);
      emit(JuzVersesLoaded(juzNumber: juzNumber, verses: verses));
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

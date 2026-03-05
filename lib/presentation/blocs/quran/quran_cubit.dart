import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/surah.dart';
import '../../../data/repositories/quran_repository.dart';
import 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final QuranRepository _repository;
  List<Surah> _allSurahs = [];

  QuranCubit(this._repository) : super(QuranInitial());

  Future<void> loadSurahs() async {
    emit(QuranLoading());
    try {
      _allSurahs = await _repository.getSurahs();
      emit(SurahsLoaded(_allSurahs));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
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

  void searchSurahs(String query) {
    if (query.isEmpty) {
      emit(SurahsLoaded(_allSurahs));
      return;
    }
    final filtered = _allSurahs
        .where(
          (s) =>
              s.nameSimple.toLowerCase().contains(query.toLowerCase()) ||
              s.translatedName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    emit(SurahsLoaded(filtered));
  }
}

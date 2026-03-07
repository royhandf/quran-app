import 'package:equatable/equatable.dart';
import '../../../data/models/juz.dart';
import '../../../data/models/surah.dart';
import '../../../data/models/ayah.dart';

abstract class QuranState extends Equatable {
  const QuranState();
  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class SurahsLoaded extends QuranState {
  final List<Surah> surahs;
  final Set<int> downloadedIds;

  const SurahsLoaded(this.surahs, {this.downloadedIds = const {}});
  @override
  List<Object?> get props => [surahs, downloadedIds];
}

class VersesLoaded extends QuranState {
  final Surah surah;
  final List<Ayah> verses;
  const VersesLoaded({required this.surah, required this.verses});
  @override
  List<Object?> get props => [surah, verses];
}

class QuranError extends QuranState {
  final String message;
  const QuranError(this.message);
  @override
  List<Object?> get props => [message];
}

class JuzsLoaded extends QuranState {
  final List<Juz> juzs;
  final Map<int, String> surahNames;

  const JuzsLoaded({required this.juzs, required this.surahNames});
  @override
  List<Object?> get props => [juzs, surahNames];
}

class JuzVersesLoaded extends QuranState {
  final int juzNumber;
  final List<Ayah> verses;

  const JuzVersesLoaded({required this.juzNumber, required this.verses});
  @override
  List<Object?> get props => [juzNumber, verses];
}

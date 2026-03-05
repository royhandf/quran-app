import 'package:equatable/equatable.dart';
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
  const SurahsLoaded(this.surahs);
  @override
  List<Object?> get props => [surahs];
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

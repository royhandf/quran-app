import 'package:equatable/equatable.dart';

abstract class AudioState extends Equatable {
  const AudioState();
  @override
  List<Object?> get props => [];
}

class AudioIdle extends AudioState {
  const AudioIdle();
}

class AudioLoading extends AudioState {
  final int ayahNumber;
  const AudioLoading(this.ayahNumber);
  @override
  List<Object?> get props => [ayahNumber];
}

class AudioPlaying extends AudioState {
  final int ayahNumber;
  final String url;
  const AudioPlaying(this.ayahNumber, this.url);
  @override
  List<Object?> get props => [ayahNumber, url];
}

class AudioPaused extends AudioState {
  final int ayahNumber;
  const AudioPaused(this.ayahNumber);
  @override
  List<Object?> get props => [ayahNumber];
}

class AudioError extends AudioState {
  final String message;
  const AudioError(this.message);
  @override
  List<Object?> get props => [message];
}

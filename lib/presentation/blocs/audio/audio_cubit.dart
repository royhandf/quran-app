import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/repositories/quran_repository.dart';
import 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  final QuranRepository _repository;
  final AudioPlayer _player = AudioPlayer();

  ConcatenatingAudioSource? _playlist;
  int _currentSurahId = -1;
  int _currentReciterId = -1;
  bool _isPlaylistLoaded = false;

  StreamSubscription? _currentIndexSub;
  StreamSubscription? _playerStateSub;

  AudioCubit(this._repository) : super(const AudioIdle()) {
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        emit(const AudioIdle());
      } else {
        _emitCurrentState();
      }
    });

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      _emitCurrentState();
    });
  }

  void _emitCurrentState() {
    if (!_isPlaylistLoaded || _playlist == null) return;

    final index = _player.currentIndex;
    if (index == null || index >= _playlist!.children.length) return;

    final source = _playlist!.children[index] as IndexedAudioSource;
    final ayahNumber = source.tag as int;

    if (_player.processingState == ProcessingState.buffering ||
        _player.processingState == ProcessingState.loading) {
      emit(AudioLoading(ayahNumber));
      return;
    }

    if (_player.playing) {
      emit(AudioPlaying(ayahNumber, '')); // url is no longer needed in UI
    } else {
      emit(AudioPaused(ayahNumber));
    }
  }

  Future<void> loadSurahAudio(int surahId, int reciterId) async {
    if (_currentSurahId == surahId && _currentReciterId == reciterId) return;

    await stop();

    _currentSurahId = surahId;
    _currentReciterId = reciterId;
    _playlist = null;
    _isPlaylistLoaded = false;

    try {
      final audioFiles = await _repository.getChapterAudioFiles(
        surahId,
        reciterId,
      );
      final ayahNumbers =
          audioFiles.keys.map((k) => int.parse(k.split(':')[1])).toList()
            ..sort();

      final children = <AudioSource>[];
      for (final num in ayahNumbers) {
        final url = audioFiles['$surahId:$num']!;
        children.add(LockCachingAudioSource(Uri.parse(url), tag: num));
      }

      _playlist = ConcatenatingAudioSource(children: children);
    } catch (_) {
      // fail silently
    }
  }

  int _getIndexForAyah(int ayahNumber) {
    if (_playlist == null) return -1;
    for (int i = 0; i < _playlist!.children.length; i++) {
      if ((_playlist!.children[i] as IndexedAudioSource).tag as int ==
          ayahNumber) {
        return i;
      }
    }
    return -1;
  }

  Future<void> toggleAyah(int surahId, int ayahNumber) async {
    final index = _getIndexForAyah(ayahNumber);
    if (index == -1) {
      emit(const AudioError('URL audio tidak tersedia'));
      emit(const AudioIdle());
      return;
    }

    if (_isPlaylistLoaded && _player.currentIndex == index) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    await _playAyahInternal(ayahNumber, index);
  }

  Future<void> playAyah(int ayahNumber) async {
    final index = _getIndexForAyah(ayahNumber);
    if (index == -1) return;

    if (_isPlaylistLoaded && _player.currentIndex == index) {
      await _player.play();
      return;
    }
    await _playAyahInternal(ayahNumber, index);
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaylistLoaded = false;
    emit(const AudioIdle());
  }

  Future<void> nextAyah(int currentAyah) async {
    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
    } else {
      await stop();
    }
  }

  Future<void> previousAyah(int currentAyah) async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
    } else {
      await stop();
    }
  }

  Future<void> _playAyahInternal(int ayahNumber, int index) async {
    if (_playlist == null) return;

    emit(AudioLoading(ayahNumber));
    try {
      if (!_isPlaylistLoaded) {
        await _player.setAudioSource(_playlist!, initialIndex: index);
        _isPlaylistLoaded = true;
      } else {
        await _player.seek(Duration.zero, index: index);
      }
      await _player.play();
    } catch (e) {
      emit(AudioError(e.toString()));
      emit(const AudioIdle());
    }
  }

  @override
  Future<void> close() async {
    _currentIndexSub?.cancel();
    _playerStateSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}

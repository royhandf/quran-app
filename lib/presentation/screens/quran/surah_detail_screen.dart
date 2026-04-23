import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/surah.dart';
import '../../../data/local/hive_service.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/audio/audio_state.dart';
import '../settings/settings_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;
  final List<Surah> allSurahs;
  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyah,
    this.allSurahs = const [],
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final Map<int, GlobalKey> _ayahKeys = {};
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;
  bool _isDownloaded = false;
  late Surah _currentSurah;

  Timer? _autoScrollTimer;
  bool _isAutoScrolling = false;
  bool _isAutoScrollPaused = false;
  double _autoScrollSpeed = 2.0;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;
    _checkDownloadStatus();
    _loadAudio();
  }

  void _loadAudio() {
    final reciterId =
        context.read<SettingsCubit>().state.selectedReciterId;
    context.read<AudioCubit>().loadSurahAudio(
      _currentSurah.id,
      reciterId,
    );
  }

  void _checkDownloadStatus() {
    final ids = context.read<QuranCubit>().repository.getDownloadedSurahIds();
    setState(() {
      _isDownloaded = ids.contains(_currentSurah.id);
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) =>
          prev.selectedReciterId != curr.selectedReciterId,
      listener: (context, _) => _loadAudio(),
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isDownloaded
                  ? Icons.download_done_rounded
                  : Icons.download_outlined,
              color: _isDownloaded ? AppColors.primary : null,
            ),
            tooltip: _isDownloaded ? 'Sudah Didownload' : 'Download Offline',
            onPressed: _isDownloaded
                ? null
                : () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloading ${_currentSurah.nameSimple}...',
                        ),
                      ),
                    );
                    try {
                      await context.read<QuranCubit>().downloadSurahSilent(
                        _currentSurah.id,
                      );
                      if (context.mounted) {
                        setState(() => _isDownloaded = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_currentSurah.nameSimple} berhasil didownload',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal download: $e')),
                        );
                      }
                    }
                  },
          ),
          IconButton(
            icon: Icon(
              _isAutoScrolling
                  ? Icons.stop_circle_outlined
                  : Icons.keyboard_double_arrow_down,
              color: _isAutoScrolling ? AppColors.primary : null,
            ),
            tooltip: _isAutoScrolling ? 'Hentikan Auto-scroll' : 'Auto-scroll',
            onPressed: _toggleAutoScroll,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (widget.allSurahs.isEmpty) return;
              final currentIndex = widget.allSurahs.indexWhere(
                (s) => s.id == _currentSurah.id,
              );
              if (currentIndex == -1) return;

              if (details.primaryVelocity! < -300) {
                if (currentIndex < widget.allSurahs.length - 1) {
                  _navigateToSurah(widget.allSurahs[currentIndex + 1]);
                }
              } else if (details.primaryVelocity! > 300) {
                if (currentIndex > 0) {
                  _navigateToSurah(widget.allSurahs[currentIndex - 1]);
                }
              }
            },
            child: BlocBuilder<QuranCubit, QuranState>(
              builder: (context, quranState) {
                if (quranState is QuranLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (quranState is QuranError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 52,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat ayat',
                          style: AppTextStyles.bodyMedium(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periksa koneksi internet dan coba lagi',
                          style: AppTextStyles.bodySmall(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.read<QuranCubit>().loadVerses(
                            _currentSurah,
                            translatorId: context
                                .read<SettingsCubit>()
                                .state
                                .translatorId,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                if (quranState is VersesLoaded) {
                  if (widget.initialAyah != null && !_hasScrolled) {
                    _hasScrolled = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToAyah(widget.initialAyah!);
                    });
                  }
                  return BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, _) {
                      return BlocListener<AudioCubit, AudioState>(
                        listener: (context, audioState) {
                          if (audioState is AudioPlaying) {
                            if (_highlightedAyah != audioState.ayahNumber) {
                              _scrollToAyah(
                                audioState.ayahNumber,
                                autoHighlight: false,
                              );
                            }
                          } else if (audioState is AudioIdle) {
                            if (_highlightedAyah != null) {
                              setState(() => _highlightedAyah = null);
                            }
                          }
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: quranState.verses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) return _buildHeader(context);
                            final ayah = quranState.verses[index - 1];
                            final bCubit = context.read<BookmarkCubit>();
                            final isBookmarked = bCubit.isBookmarked(
                              _currentSurah.id,
                              ayah.verseNumber,
                            );

                            _ayahKeys.putIfAbsent(
                              ayah.verseNumber,
                              () => GlobalKey(),
                            );

                            return BlocBuilder<AudioCubit, AudioState>(
                              builder: (context, audioState) {
                                final isThisPlaying =
                                    audioState is AudioPlaying &&
                                    audioState.ayahNumber == ayah.verseNumber;
                                final isHighlighted =
                                    _highlightedAyah == ayah.verseNumber ||
                                    isThisPlaying;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  key: _ayahKeys[ayah.verseNumber],
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isHighlighted
                                        ? AppColors.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.card(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isHighlighted
                                        ? Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.5,
                                            ),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.15),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${ayah.verseNumber}',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.library_add_check_outlined,
                                            ),
                                            tooltip: 'Tandai Terakhir Baca',
                                            onPressed: () async {
                                              await GetIt.I<HiveService>()
                                                  .saveLastRead(
                                                    surahId: _currentSurah.id,
                                                    surahName: _currentSurah
                                                        .nameSimple,
                                                    ayahNumber:
                                                        ayah.verseNumber,
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Ayat ${ayah.verseNumber} ditandai sebagai terakhir baca',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isBookmarked
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_border,
                                              color: isBookmarked
                                                  ? AppColors.primary
                                                  : null,
                                            ),
                                            onPressed: () =>
                                                bCubit.toggleBookmark(
                                                  surahId: _currentSurah.id,
                                                  surahName:
                                                      _currentSurah.nameSimple,
                                                  ayahNumber: ayah.verseNumber,
                                                  ayahText: ayah.textUthmani,
                                                ),
                                          ),
                                          BlocBuilder<AudioCubit, AudioState>(
                                            builder: (context, audioState) {
                                              final isThisPlaying =
                                                  audioState is AudioPlaying &&
                                                  audioState.ayahNumber ==
                                                      ayah.verseNumber;
                                              final isThisPaused =
                                                  audioState is AudioPaused &&
                                                  audioState.ayahNumber ==
                                                      ayah.verseNumber;
                                              final isThisLoading =
                                                  audioState is AudioLoading &&
                                                  audioState.ayahNumber ==
                                                      ayah.verseNumber;
                                              return isThisLoading
                                                  ? const SizedBox(
                                                      width: 48,
                                                      height: 48,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                          12,
                                                        ),
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    )
                                                  : IconButton(
                                                      icon: Icon(
                                                        isThisPlaying
                                                            ? Icons
                                                                  .pause_circle_outline
                                                            : isThisPaused
                                                            ? Icons
                                                                  .play_circle_filled
                                                            : Icons
                                                                  .play_circle_outline,
                                                        color:
                                                            (isThisPlaying ||
                                                                isThisPaused)
                                                            ? AppColors.primary
                                                            : null,
                                                      ),
                                                      onPressed: () => context
                                                          .read<AudioCubit>()
                                                          .toggleAyah(
                                                            _currentSurah.id,
                                                            ayah.verseNumber,
                                                          ),
                                                    );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      RichText(
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  settings.arabicFontType ==
                                                      'IndoPak'
                                                  ? ayah.textIndoPak
                                                  : ayah.textUthmani,
                                              style: AppTextStyles.arabicLarge(
                                                context,
                                                fontSize:
                                                    settings.arabicFontSize,
                                                fontType:
                                                    settings.arabicFontType,
                                              ),
                                            ),
                                            if (settings.showArabicNumbers)
                                              TextSpan(
                                                text:
                                                    ' \u06DD${toArabicNumeral(ayah.verseNumber)} ',
                                                style:
                                                    AppTextStyles.arabicLarge(
                                                      context,
                                                      fontSize:
                                                          (settings.arabicFontSize *
                                                                  0.75)
                                                              .clamp(14, 24),
                                                      fontType: settings
                                                          .arabicFontType,
                                                    ).copyWith(
                                                      color: AppColors.primary,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (settings.showLatin &&
                                          ayah.textTransliteration != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          ayah.textTransliteration!,
                                          style: TextStyle(
                                            fontSize: settings.latinFontSize,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                      if (settings.showTranslation &&
                                          ayah.textTranslation != null) ...[
                                        Divider(
                                          height: 24,
                                          color: AppColors.dividerColor(
                                            context,
                                          ),
                                        ),
                                        Text(
                                          ayah.textTranslation!,
                                          style: TextStyle(
                                            fontSize:
                                                settings.translationFontSize,
                                            color: AppColors.textSecondary(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          if (_isAutoScrolling) _buildAutoScrollControlPanel(),
          BlocBuilder<AudioCubit, AudioState>(
            builder: (context, state) {
              if (state is AudioIdle) return const SizedBox.shrink();
              return _buildAudioControlPanel(context, state);
            },
          ),
        ],
      ),
    ),
  );
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      _isAutoScrollPaused = false;
      _autoScrollSpeed = 2.0;
    });
    if (_isAutoScrolling) {
      _startAutoScrollTimer();
    } else {
      _stopAutoScrollTimer();
    }
  }

  void _startAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (_isAutoScrollPaused) return;
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        _toggleAutoScroll();
        return;
      }

      _scrollController.jumpTo(
        (currentScroll + _autoScrollSpeed).clamp(0.0, maxScroll),
      );
    });
  }

  void _stopAutoScrollTimer() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _changeAutoScrollSpeed(double delta) {
    setState(() {
      _autoScrollSpeed = (_autoScrollSpeed + delta).clamp(0.0, 5.0);
    });
  }

  Widget _buildAutoScrollControlPanel() {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _changeAutoScrollSpeed(-0.5),
                tooltip: 'Kurangi Kecepatan',
              ),
              IconButton(
                icon: Icon(
                  _isAutoScrollPaused ? Icons.play_arrow : Icons.pause,
                ),
                onPressed: () {
                  setState(() {
                    _isAutoScrollPaused = !_isAutoScrollPaused;
                  });
                },
                tooltip: _isAutoScrollPaused ? 'Lanjut' : 'Jeda',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _changeAutoScrollSpeed(0.5),
                tooltip: 'Tambah Kecepatan',
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: _toggleAutoScroll,
                tooltip: 'Tutup',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioControlPanel(BuildContext context, AudioState state) {
    final cubit = context.read<AudioCubit>();
    int? currentAyah;
    if (state is AudioPlaying) currentAyah = state.ayahNumber;
    if (state is AudioPaused) currentAyah = state.ayahNumber;
    if (state is AudioLoading) currentAyah = state.ayahNumber;

    if (currentAyah == null) return const SizedBox.shrink();

    return Positioned(
      bottom: _isAutoScrolling ? 100 : 32,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' Ayat $currentAyah ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () => cubit.previousAyah(currentAyah!),
                tooltip: 'Mundur',
              ),
              IconButton(
                icon: Icon(
                  state is AudioPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 36,
                  color: AppColors.primary,
                ),
                onPressed: () => state is AudioPlaying
                    ? cubit.pause()
                    : cubit.playAyah(currentAyah!),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => cubit.nextAyah(currentAyah!),
                tooltip: 'Maju',
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.withValues(alpha: 0.5),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              IconButton(
                icon: const Icon(Icons.stop, color: Colors.red),
                onPressed: () => cubit.stop(),
                tooltip: 'Berhenti',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSurah(Surah surah) {
    // Hentikan auto-scroll sebelum ganti surah
    if (_isAutoScrolling) {
      _stopAutoScrollTimer();
      setState(() {
        _isAutoScrolling = false;
        _isAutoScrollPaused = false;
      });
    }
    final ids = context.read<QuranCubit>().repository.getDownloadedSurahIds();
    context.read<AudioCubit>().stop();
    setState(() {
      _currentSurah = surah;
      _ayahKeys.clear();
      _hasScrolled = false;
      _isDownloaded = ids.contains(surah.id);
      _highlightedAyah = null;
    });
    _scrollController.jumpTo(0);
    context.read<QuranCubit>().loadVerses(
      surah,
      translatorId: context.read<SettingsCubit>().state.translatorId,
    );
    _loadAudio();
  }

  int? _highlightedAyah;

  void _scrollToAyah(int ayahNumber, {bool autoHighlight = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[ayahNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        ).then((_) {
          if (autoHighlight) _highlightAyah(ayahNumber);
        });
      } else {
        final estimatedOffset = 150.0 + (ayahNumber - 1) * 200.0;
        _scrollController
            .animateTo(
              estimatedOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            )
            .then((_) {
              Future.delayed(const Duration(milliseconds: 100), () {
                final newKey = _ayahKeys[ayahNumber];
                if (newKey?.currentContext != null) {
                  Scrollable.ensureVisible(
                    newKey!.currentContext!,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: 0.1,
                  ).then((_) => _highlightAyah(ayahNumber));
                } else {
                  if (autoHighlight) _highlightAyah(ayahNumber);
                }
              });
            });
      }
    });
  }

  void _highlightAyah(int ayahNumber) {
    if (!mounted) return;
    setState(() {
      _highlightedAyah = ayahNumber;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _highlightedAyah == ayahNumber) {
        setState(() {
          _highlightedAyah = null;
        });
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    if (_currentSurah.id == 9) return const SizedBox(height: 8);

    final place = _currentSurah.revelationPlace == 'makkah'
        ? 'Mekah'
        : 'Madinah';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Surah? prevSurah;
    Surah? nextSurah;

    if (widget.allSurahs.isNotEmpty) {
      final currentIndex = widget.allSurahs.indexWhere(
        (s) => s.id == _currentSurah.id,
      );
      if (currentIndex > 0) {
        prevSurah = widget.allSurahs[currentIndex - 1];
      }
      if (currentIndex != -1 && currentIndex < widget.allSurahs.length - 1) {
        nextSurah = widget.allSurahs[currentIndex + 1];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 1,
                  child: prevSurah != null
                      ? GestureDetector(
                          onTap: () => _navigateToSurah(prevSurah!),
                          child: Text(
                            '${prevSurah.id}. ${prevSurah.nameSimple}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        )
                      : const SizedBox(),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentSurah.id}. ${_currentSurah.nameSimple}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: nextSurah != null
                      ? GestureDetector(
                          onTap: () => _navigateToSurah(nextSurah!),
                          child: Text(
                            '${nextSurah.id}. ${nextSurah.nameSimple}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Text(
                    _currentSurah.translatedName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_currentSurah.versesCount} Ayat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_currentSurah.id != 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

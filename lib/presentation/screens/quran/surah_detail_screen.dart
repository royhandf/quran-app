import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/surah.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/audio/audio_state.dart';
import '../../widgets/star_icon_container.dart';

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
    final reciterId = context.read<SettingsCubit>().state.selectedReciterId;
    context.read<AudioCubit>().loadSurahAudio(_currentSurah.id, reciterId);
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
    _autoScrollResumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Timer? _autoScrollResumeTimer;

  void _pauseAutoScrollTemporarily() {
    if (_isAutoScrollPaused) return;
    setState(() => _isAutoScrollPaused = true);
    _autoScrollResumeTimer?.cancel();
    _autoScrollResumeTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isAutoScrolling) {
        setState(() => _isAutoScrollPaused = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) =>
          prev.selectedReciterId != curr.selectedReciterId,
      listener: (context, _) => _loadAudio(),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground(context),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.homeBackground(context),
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.homeInk(context)),
          title: Column(
            children: [
              Text(
                _currentSurah.nameSimple,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTokens.fontLatin,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.homeInk(context),
                ),
              ),
              Text(
                _currentSurah.translatedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTokens.tileSubtitle(context),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDownloaded
                    ? Icons.download_done_rounded
                    : Icons.download_outlined,
                color: _isDownloaded ? AppColors.forest : null,
              ),
              tooltip: _isDownloaded ? 'Sudah Didownload' : 'Download Offline',
              onPressed: _isDownloaded
                  ? null
                  : () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mengunduh ${_currentSurah.nameSimple}…',
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
                    : Icons.keyboard_double_arrow_down_rounded,
                color: _isAutoScrolling ? AppColors.forest : null,
              ),
              tooltip: _isAutoScrolling
                  ? 'Hentikan Auto-scroll'
                  : 'Auto-scroll',
              onPressed: _toggleAutoScroll,
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
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.forest),
                    );
                  }
                  if (quranState is QuranError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StarIconContainer(
                            icon: Icons.wifi_off_rounded,
                            containerColor: AppColors.homeStarSecondary(
                              context,
                            ),
                            iconColor: AppColors.homeInkSecondary(context),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Gagal memuat ayat',
                            style: AppTokens.tileTitle(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Periksa koneksi internet dan coba lagi',
                            style: AppTokens.tileSubtitle(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.pageMargin,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: () => context
                                    .read<QuranCubit>()
                                    .loadVerses(_currentSurah),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.forest,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTokens.buttonRadius,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Coba Lagi',
                                  style: TextStyle(
                                    fontFamily: AppTokens.fontLatin,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
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
                              if (_isAutoScrolling) {
                                _toggleAutoScroll();
                              }
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
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (_isAutoScrolling &&
                                  !_isAutoScrollPaused &&
                                  notification is ScrollUpdateNotification &&
                                  notification.dragDetails != null) {
                                _pauseAutoScrollTemporarily();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                120,
                              ),
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
                                        audioState.ayahNumber ==
                                            ayah.verseNumber;
                                    final isHighlighted =
                                        _highlightedAyah == ayah.verseNumber ||
                                        isThisPlaying;

                                    final isDark =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      key: _ayahKeys[ayah.verseNumber],
                                      margin: const EdgeInsets.only(
                                        bottom: AppTokens.itemGap,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? (isDark
                                                  ? AppColors.sageLight
                                                        .withValues(alpha: 0.10)
                                                  : AppColors.forest.withValues(
                                                      alpha: 0.12,
                                                    ))
                                            : AppColors.homeSurface(context),
                                        borderRadius: BorderRadius.circular(
                                          AppTokens.cardRadius,
                                        ),
                                        border: isHighlighted
                                            ? Border.all(
                                                color: isDark
                                                    ? AppColors.sageLight
                                                    : AppColors.forest,
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
                                              StarIconContainer(
                                                label: '${ayah.verseNumber}',
                                                containerColor: isThisPlaying
                                                    ? AppColors.forest
                                                    : AppColors.homeStarSecondary(
                                                        context,
                                                      ),
                                                iconColor: isThisPlaying
                                                    ? Colors.white
                                                    : AppColors.homeArabicSecondary(
                                                        context,
                                                      ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: Icon(
                                                  isBookmarked
                                                      ? Icons.bookmark_rounded
                                                      : Icons
                                                            .bookmark_border_rounded,
                                                  color: isBookmarked
                                                      ? AppColors.forest
                                                      : AppColors.homeInkSecondary(
                                                          context,
                                                        ),
                                                ),
                                                onPressed: () =>
                                                    bCubit.toggleBookmark(
                                                      surahId: _currentSurah.id,
                                                      surahName: _currentSurah
                                                          .nameSimple,
                                                      ayahNumber:
                                                          ayah.verseNumber,
                                                      ayahText:
                                                          ayah.textUthmani,
                                                    ),
                                              ),
                                              BlocBuilder<
                                                AudioCubit,
                                                AudioState
                                              >(
                                                builder: (context, audioState) {
                                                  final isThisPlaying =
                                                      audioState
                                                          is AudioPlaying &&
                                                      audioState.ayahNumber ==
                                                          ayah.verseNumber;
                                                  final isThisPaused =
                                                      audioState
                                                          is AudioPaused &&
                                                      audioState.ayahNumber ==
                                                          ayah.verseNumber;
                                                  final isThisLoading =
                                                      audioState
                                                          is AudioLoading &&
                                                      audioState.ayahNumber ==
                                                          ayah.verseNumber;
                                                  return isThisLoading
                                                      ? const SizedBox(
                                                          width: 48,
                                                          height: 48,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: AppColors
                                                                      .forest,
                                                                ),
                                                          ),
                                                        )
                                                      : IconButton(
                                                          icon: Icon(
                                                            isThisPlaying
                                                                ? Icons
                                                                      .pause_circle_outline_rounded
                                                                : isThisPaused
                                                                ? Icons
                                                                      .play_circle_filled_rounded
                                                                : Icons
                                                                      .play_circle_outline_rounded,
                                                            color:
                                                                (isThisPlaying ||
                                                                    isThisPaused)
                                                                ? AppColors
                                                                      .forest
                                                                : AppColors.homeInkSecondary(
                                                                    context,
                                                                  ),
                                                          ),
                                                          onPressed: () => context
                                                              .read<
                                                                AudioCubit
                                                              >()
                                                              .toggleAyah(
                                                                _currentSurah
                                                                    .id,
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
                                                  style: TextStyle(
                                                    fontFamily:
                                                        settings.arabicFontType ==
                                                            'IndoPak'
                                                        ? 'Lateef'
                                                        : 'ScheherazadeNew',
                                                    fontSize:
                                                        settings.arabicFontSize,
                                                    height: 2.0,
                                                    color: AppColors.homeInk(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                                if (settings.showArabicNumbers)
                                                  TextSpan(
                                                    text:
                                                        ' \u06DD${toArabicNumeral(ayah.verseNumber)} ',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          settings.arabicFontType ==
                                                              'IndoPak'
                                                          ? 'Lateef'
                                                          : 'ScheherazadeNew',
                                                      fontSize:
                                                          (settings.arabicFontSize *
                                                                  0.75)
                                                              .clamp(14, 24),
                                                      height: 2.0,
                                                      color: AppColors.gold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (settings.showLatin &&
                                              ayah.textTransliteration !=
                                                  null) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              ayah.textTransliteration!,
                                              style: TextStyle(
                                                fontSize:
                                                    settings.latinFontSize,
                                                fontStyle: FontStyle.italic,
                                                color:
                                                    AppColors.homeArabicSecondary(
                                                      context,
                                                    ),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                          if (settings.showTranslation &&
                                              ayah.textTranslation != null) ...[
                                            Divider(
                                              height: 24,
                                              color: AppColors.homeDivider(
                                                context,
                                              ),
                                            ),
                                            Text(
                                              ayah.textTranslation!,
                                              style: TextStyle(
                                                fontSize: settings
                                                    .translationFontSize,
                                                height: 1.5,
                                                color: AppColors.homeInk(
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
      context.read<AudioCubit>().stop();
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
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: safeBottom + 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, color: Colors.white),
                onPressed: () => _changeAutoScrollSpeed(-0.5),
                tooltip: 'Kurangi Kecepatan',
              ),
              IconButton(
                icon: Icon(
                  _isAutoScrollPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isAutoScrollPaused = !_isAutoScrollPaused;
                  });
                },
                tooltip: _isAutoScrollPaused ? 'Lanjut' : 'Jeda',
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => _changeAutoScrollSpeed(0.5),
                tooltip: 'Tambah Kecepatan',
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.25),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.gold),
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

    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: safeBottom + 20,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
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
                  fontFamily: AppTokens.fontLatin,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.sageLight,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                ),
                onPressed: () => cubit.previousAyah(currentAyah!),
                tooltip: 'Mundur',
              ),
              IconButton(
                icon: Icon(
                  state is AudioPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 36,
                  color: Colors.white,
                ),
                onPressed: () => state is AudioPlaying
                    ? cubit.pause()
                    : cubit.playAyah(currentAyah!),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                onPressed: () => cubit.nextAyah(currentAyah!),
                tooltip: 'Maju',
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.25),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              IconButton(
                icon: const Icon(Icons.stop_rounded, color: AppColors.gold),
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
      _isDownloaded = ids.contains(surah.id);
      _highlightedAyah = null;
    });
    _scrollController.jumpTo(0);
    context.read<QuranCubit>().loadVerses(surah);
    _loadAudio();
  }

  int? _highlightedAyah;

  void _scrollToAyah(
    int ayahNumber, {
    bool autoHighlight = true,
    int attempt = 0,
  }) {
    if (attempt > 40) {
      if (autoHighlight) _highlightAyah(ayahNumber);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keyContext = _ayahKeys[ayahNumber]?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        ).then((_) {
          if (autoHighlight) _highlightAyah(ayahNumber);
        });
        return;
      }

      final max = _scrollController.position.maxScrollExtent;
      int? minBuilt;
      int? maxBuilt;
      _ayahKeys.forEach((number, key) {
        if (key.currentContext != null) {
          if (minBuilt == null || number < minBuilt!) minBuilt = number;
          if (maxBuilt == null || number > maxBuilt!) maxBuilt = number;
        }
      });

      if (minBuilt == null || max <= 0) {
        _scrollToAyah(
          ayahNumber,
          autoHighlight: autoHighlight,
          attempt: attempt + 1,
        );
        return;
      }

      final total = (_currentSurah.versesCount > 1)
          ? _currentSurah.versesCount
          : 1;
      final avgHeight = max / total;

      double target;
      if (ayahNumber > maxBuilt!) {
        target =
            _scrollController.offset + (ayahNumber - maxBuilt!) * avgHeight;
      } else if (ayahNumber < minBuilt!) {
        target =
            _scrollController.offset - (minBuilt! - ayahNumber) * avgHeight;
      } else {
        target = _scrollController.offset;
      }
      _scrollController.jumpTo(target.clamp(0.0, max));
      _scrollToAyah(
        ayahNumber,
        autoHighlight: autoHighlight,
        attempt: attempt + 1,
      );
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
    final place = _currentSurah.revelationPlace == 'makkah'
        ? 'Mekah'
        : 'Madinah';

    List<Surah> window = [];
    final currentIndex = widget.allSurahs.indexWhere(
      (s) => s.id == _currentSurah.id,
    );
    if (currentIndex != -1) {
      final start = (currentIndex - 1)
          .clamp(0, math.max(0, widget.allSurahs.length - 3))
          .toInt();
      final end = math.min(start + 3, widget.allSurahs.length);
      window = widget.allSurahs.sublist(start, end);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final s in window)
              _buildTab(
                '${s.id}. ${s.nameSimple}',
                s.id == _currentSurah.id,
                s.id == _currentSurah.id ? null : () => _navigateToSurah(s),
              ),
          ],
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.homeDivider(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  place,
                  textAlign: TextAlign.center,
                  style: AppTokens.tileSubtitle(context),
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: AppColors.homeDivider(context),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _currentSurah.translatedName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTokens.tileSubtitle(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.homeInk(context),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: AppColors.homeDivider(context),
              ),
              Expanded(
                child: Text(
                  '${_currentSurah.versesCount} ayat',
                  textAlign: TextAlign.center,
                  style: AppTokens.tileSubtitle(context),
                ),
              ),
            ],
          ),
        ),
        if (_currentSurah.id != 1 && _currentSurah.id != 9)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 24,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: AppColors.homeInk(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildTab(String label, bool selected, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? AppColors.forest
                    : AppColors.homeDivider(context),
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTokens.fontLatin,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.forest
                  : AppColors.homeInkSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/utils/arabic_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/surah.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/settings/settings_cubit.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;
  const SurahDetailScreen({super.key, required this.surah, this.initialAyah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final Map<int, GlobalKey> _ayahKeys = {};
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.nameSimple),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, quranState) {
          if (quranState is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (quranState is QuranError) {
            return Center(child: Text('Error: ${quranState.message}'));
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
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: quranState.verses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildHeader(context);
                    final ayah = quranState.verses[index - 1];
                    final bCubit = context.read<BookmarkCubit>();
                    final isBookmarked = bCubit.isBookmarked(
                      widget.surah.id,
                      ayah.verseNumber,
                    );

                    _ayahKeys.putIfAbsent(ayah.verseNumber, () => GlobalKey());

                    return Container(
                      key: _ayahKeys[ayah.verseNumber],
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
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
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isBookmarked
                                      ? AppColors.primary
                                      : null,
                                ),
                                onPressed: () => bCubit.toggleBookmark(
                                  surahId: widget.surah.id,
                                  surahName: widget.surah.nameSimple,
                                  ayahNumber: ayah.verseNumber,
                                  ayahText: ayah.textArabic,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            settings.showArabicNumbers
                                ? '${ayah.textArabic} ﴿${toArabicNumeral(ayah.verseNumber)}﴾'
                                : ayah.textArabic,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.arabicLarge(
                              context,
                              fontSize: settings.arabicFontSize,
                            ),
                          ),
                          if (settings.showLatin) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Transliterasi ayat ${ayah.verseNumber}',
                              style: TextStyle(
                                fontSize: settings.latinFontSize,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                          // Terjemahan
                          if (settings.showTranslation &&
                              ayah.textTranslation != null) ...[
                            Divider(
                              height: 24,
                              color: AppColors.dividerColor(context),
                            ),
                            Text(
                              ayah.textTranslation!,
                              style: TextStyle(
                                fontSize: settings.translationFontSize,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _scrollToAyah(int ayahNumber) {
    // Delay to let ListView build, then try ensureVisible
    // If key not rendered yet, estimate position based on index
    Future.delayed(const Duration(milliseconds: 300), () {
      final key = _ayahKeys[ayahNumber];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      } else {
        // Estimate: header ~150px, each ayah card ~250px
        final targetIndex = ayahNumber; // index 0 = header, 1 = ayah 1
        final estimatedOffset = 150.0 + (targetIndex - 1) * 250.0;
        _scrollController.animateTo(
          estimatedOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.surah.id == 9) return const SizedBox(height: 8);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primaryDark.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.surah.nameSimple,
            style: AppTextStyles.headingMedium(context),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.surah.translatedName} • ${widget.surah.versesCount} Ayat • ${widget.surah.revelationPlace == 'makkah' ? 'Makkiyah' : 'Madaniyah'}',
            style: AppTextStyles.bodySmall(context),
          ),
          if (widget.surah.id != 1) ...[
            const SizedBox(height: 16),
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: AppTextStyles.arabicLarge(context, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

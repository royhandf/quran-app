import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/bookmark.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../widgets/sheet_shell.dart';
import '../../widgets/star_icon_container.dart';
import '../quran/surah_detail_screen.dart';
import '../quran/surah_list_screen.dart';

class LastReadScreen extends StatefulWidget {
  const LastReadScreen({super.key});

  static void openBookmark(
    BuildContext context,
    Bookmark bookmark, {
    VoidCallback? onFallback,
  }) {
    final quranCubit = context.read<QuranCubit>();
    final surah = quranCubit.findSurahById(bookmark.surahId);

    if (surah == null) {
      if (onFallback != null) {
        onFallback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data surah. Periksa koneksi internet.'),
          ),
        );
      }
      return;
    }

    final reciterId = context.read<SettingsCubit>().state.selectedReciterId;
    final repo = quranCubit.repository;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  QuranCubit(quranCubit.repository)..loadVerses(surah),
            ),
            BlocProvider(
              create: (_) =>
                  AudioCubit(repo)..loadSurahAudio(surah.id, reciterId),
            ),
          ],
          child: SurahDetailScreen(
            surah: surah,
            initialAyah: bookmark.ayahNumber,
            allSurahs: quranCubit.allSurahs,
          ),
        ),
      ),
    );
  }

  @override
  State<LastReadScreen> createState() => _LastReadScreenState();
}

class _LastReadScreenState extends State<LastReadScreen> {
  @override
  void initState() {
    super.initState();
    final quranCubit = context.read<QuranCubit>();
    if (quranCubit.allSurahs.isEmpty) {
      quranCubit.loadSurahs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Penanda', style: AppTokens.pageTitle(context)),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is! BookmarkLoaded) return const SizedBox();
          if (state.bookmarks.isEmpty) return _buildEmptyState(context);
          return _buildBookmarkList(context, state.bookmarks);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StarIconContainer(
                  icon: Icons.bookmark_rounded,
                  size: 64,
                  containerColor: AppColors.homeStarSecondary(context),
                  iconColor: AppColors.homeArabicSecondary(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'Belum ada penanda',
                  style: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeInk(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tandai ayat saat membaca, dan ayat itu\nakan muncul di sini.',
                  style: AppTokens.tileSubtitle(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageMargin,
              0,
              AppTokens.pageMargin,
              20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SurahListScreen()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Mulai Membaca',
                  style: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkList(BuildContext context, List<Bookmark> bookmarks) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pageMargin,
        8,
        AppTokens.pageMargin,
        32,
      ),
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.itemGap),
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        return _BookmarkRow(
          bookmark: bm,
          onTap: () => LastReadScreen.openBookmark(context, bm),
          onDelete: () => _showDeleteSheet(context, bm),
        );
      },
    );
  }

  void _showDeleteSheet(BuildContext context, Bookmark bm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Hapus penanda',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${bm.surahName}", Ayat ${bm.ayahNumber} akan dihapus dari '
              'daftar penanda.',
              style: AppTokens.tileSubtitle(context).copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'Batal',
                    background: AppColors.homeOptionSurface(context),
                    foreground: AppColors.homeInk(context),
                    onTap: () => Navigator.pop(sheetContext),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetButton(
                    label: 'Hapus',
                    background: AppColors.homeDanger(context),
                    foreground: Colors.white,
                    onTap: () {
                      context.read<BookmarkCubit>().toggleBookmark(
                        surahId: bm.surahId,
                        surahName: bm.surahName,
                        ayahNumber: bm.ayahNumber,
                        ayahText: bm.ayahText,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkRow({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff < 7) return '$diff hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.homeSurface(context),
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
        ),
        child: Row(
          children: [
            StarIconContainer(
              icon: Icons.bookmark_border_rounded,
              containerColor: AppColors.homeStarSecondary(context),
              iconColor: AppColors.homeArabicSecondary(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bookmark.surahName,
                    style: AppTokens.tileTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _AyatPill(ayat: bookmark.ayahNumber),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _formatDate(bookmark.createdAt),
                          style: AppTokens.tileSubtitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.homeInkSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyatPill extends StatelessWidget {
  final int ayat;

  const _AyatPill({required this.ayat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.homeStarSecondary(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'Ayat $ayat',
        style: TextStyle(
          fontFamily: AppTokens.fontLatin,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.homeArabicSecondary(context),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

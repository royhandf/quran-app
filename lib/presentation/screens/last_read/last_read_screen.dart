import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../data/models/bookmark.dart';
import '../../../core/di/injection.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../quran/surah_detail_screen.dart';

class LastReadScreen extends StatefulWidget {
  const LastReadScreen({super.key});

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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Penanda', style: AppTextStyles.headingSmall(context)),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoaded) {
            if (state.bookmarks.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildBookmarkList(context, state.bookmarks);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada penanda',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tandai ayat favorit saat membaca\ndengan menekan ikon bookmark',
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(BuildContext context, List<Bookmark> bookmarks) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bm = bookmarks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: Key(bm.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            confirmDismiss: (_) => _confirmDelete(context),
            onDismissed: (_) {
              context.read<BookmarkCubit>().toggleBookmark(
                surahId: bm.surahId,
                surahName: bm.surahName,
                ayahNumber: bm.ayahNumber,
                ayahText: bm.ayahText,
              );
            },
            child: _BookmarkCard(
              bookmark: bm,
              onTap: () => _navigateToSurah(bm.surahId, bm.ayahNumber),
              onDelete: () async {
                final confirmed = await _confirmDelete(context);
                if (confirmed == true && context.mounted) {
                  context.read<BookmarkCubit>().toggleBookmark(
                    surahId: bm.surahId,
                    surahName: bm.surahName,
                    ayahNumber: bm.ayahNumber,
                    ayahText: bm.ayahText,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Penanda?'),
        content: const Text('Anda yakin ingin menghapus penanda ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToSurah(int surahId, int ayahNumber) {
    final quranCubit = context.read<QuranCubit>();
    final surah = quranCubit.findSurahById(surahId);

    if (surah != null) {
      final reciterId = context.read<SettingsCubit>().state.selectedReciterId;
      final repo = getIt<QuranRepository>();
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
              initialAyah: ayahNumber,
              allSurahs: quranCubit.allSurahs,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data surah. Periksa koneksi internet.'),
        ),
      );
    }
  }
}

// ── Bookmark card widget ───────────────────────────────────────────────────────
class _BookmarkCard extends StatefulWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  bool _pressed = false;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bm = widget.bookmark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.dividerColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon bookmark
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bm.surahName,
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Ayat ${bm.ayahNumber}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(bm.createdAt),
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

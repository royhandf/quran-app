import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/quran_repository.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Penanda',
                style: AppTextStyles.headingSmall(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkLoaded) {
            if (state.bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: AppColors.textSecondary(context),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada penanda',
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tandai ayat favorit saat membaca Al-Qur\'an',
                      style: AppTextStyles.bodySmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.bookmarks.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: AppColors.dividerColor(context)),
              itemBuilder: (context, index) {
                final bm = state.bookmarks[index];
                return Dismissible(
                  key: Key(bm.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.15),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      bm.surahName,
                      style: AppTextStyles.bodyLarge(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Ayat ${bm.ayahNumber}',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.textSecondary(context),
                        size: 20,
                      ),
                      onPressed: () async {
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
                    onTap: () => _navigateToSurah(bm.surahId, bm.ayahNumber),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
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

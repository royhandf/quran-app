import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/audio/audio_cubit.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<QuranCubit>().loadSurahs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, int surahId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Offline'),
        content: const Text('Hapus data surah yang sudah didownload?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuranCubit>().deleteSurah(surahId);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyMedium(context),
                decoration: InputDecoration(
                  hintText: 'Cari surah...',
                  hintStyle: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<QuranCubit>().searchSurahs(query);
                  if (_tabController.index != 0) {
                    _tabController.animateTo(0);
                  }
                },
              )
            : Row(
                children: [
                  Flexible(
                    child: Text(
                      "Baca Qur'an",
                      style: AppTextStyles.headingSmall(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<QuranCubit>().searchSurahs('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_color_text),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'SURAH'),
            Tab(text: 'BOOKMARK'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSurahTab(), _buildBookmarkTab()],
      ),
    );
  }

  Widget _buildSurahNumber(BuildContext context, int number) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTab() {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is QuranError) {
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
                  'Gagal memuat daftar surah',
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
                  onPressed: () => context.read<QuranCubit>().loadSurahs(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        if (state is SurahsLoaded) {
          final lastRead = GetIt.I<HiveService>().getLastRead();
          return ListView.separated(
            itemCount: state.surahs.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 70,
              color: AppColors.dividerColor(context),
            ),
            itemBuilder: (context, index) {
              final surah = state.surahs[index];
              final isLastRead =
                  lastRead != null && lastRead['surahId'] == surah.id;
              return Container(
                color: isLastRead
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _buildSurahNumber(context, surah.id),
                  title: Text(
                    surah.nameSimple,
                    style: AppTextStyles.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${surah.revelationPlace == 'makkah' ? 'Mekah' : 'Madinah'} | ${surah.versesCount} Ayat',
                    style: AppTextStyles.bodySmall(context),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surah.nameArabic,
                        style: AppTextStyles.arabicMedium(context),
                      ),
                      const SizedBox(width: 8),
                      state.downloadedIds.contains(surah.id)
                          ? GestureDetector(
                              onLongPress: () =>
                                  _showDeleteDialog(context, surah.id),
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            )
                          : GestureDetector(
                              onTap: () => context
                                  .read<QuranCubit>()
                                  .downloadSurah(surah.id),
                              child: Icon(
                                Icons.download_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) =>
                                  QuranCubit(
                                    context.read<QuranCubit>().repository,
                                  )..loadVerses(
                                    surah,
                                    translatorId: context
                                        .read<SettingsCubit>()
                                        .state
                                        .translatorId,
                                  ),
                            ),
                            BlocProvider(
                              create: (_) => AudioCubit(
                                context.read<QuranCubit>().repository,
                              ),
                            ),
                          ],
                          child: SurahDetailScreen(
                            surah: surah,
                            allSurahs: context.read<QuranCubit>().allSurahs,
                          ),
                        ),
                      ),
                    ).then((_) {
                      if (!context.mounted) return;
                      context.read<QuranCubit>().refreshDownloadStatus();
                    });
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBookmarkTab() {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkLoaded) {
          if (state.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada bookmark',
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: state.bookmarks.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: AppColors.dividerColor(context)),
            itemBuilder: (context, index) {
              final bm = state.bookmarks[index];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: AppColors.primary),
                title: Text(
                  bm.surahName,
                  style: AppTextStyles.bodyLarge(context),
                ),
                subtitle: Text(
                  'Ayat ${bm.ayahNumber}',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context.read<BookmarkCubit>().toggleBookmark(
                    surahId: bm.surahId,
                    surahName: bm.surahName,
                    ayahNumber: bm.ayahNumber,
                    ayahText: bm.ayahText,
                  ),
                ),
                onTap: () {
                  final surah = context.read<QuranCubit>().findSurahById(
                    bm.surahId,
                  );
                  if (surah != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) =>
                                  QuranCubit(
                                    context.read<QuranCubit>().repository,
                                  )..loadVerses(
                                    surah,
                                    translatorId: context
                                        .read<SettingsCubit>()
                                        .state
                                        .translatorId,
                                  ),
                            ),
                            BlocProvider(
                              create: (_) => AudioCubit(
                                context.read<QuranCubit>().repository,
                              ),
                            ),
                          ],
                          child: SurahDetailScreen(
                            surah: surah,
                            initialAyah: bm.ayahNumber,
                            allSurahs: context.read<QuranCubit>().allSurahs,
                          ),
                        ),
                      ),
                    ).then((_) {
                      if (!context.mounted) return;
                      context.read<QuranCubit>().refreshDownloadStatus();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Data surah belum dimuat. Kembali ke halaman utama terlebih dahulu.',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/audio/audio_cubit.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<QuranCubit>().loadSurahs();
  }

  @override
  void dispose() {
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
        ],
      ),
      body: _buildSurahList(),
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

  Widget _buildSurahList() {
    return BlocConsumer<QuranCubit, QuranState>(
      listener: (context, state) {
        if (state is SurahsLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
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
              final isDownloading = state.downloadingSurahId == surah.id;
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
                      if (isDownloading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else if (state.downloadedIds.contains(surah.id))
                        GestureDetector(
                          onLongPress: () =>
                              _showDeleteDialog(context, surah.id),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        )
                      else
                        GestureDetector(
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
                                  )..loadVerses(surah),
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
}
